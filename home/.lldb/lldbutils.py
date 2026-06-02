"""Small personal LLDB commands loaded from ~/.lldbinit."""

import os
import re
import shlex
import time

import lldb


def _selected_frame(debugger):
    target = debugger.GetSelectedTarget()
    if not target or not target.IsValid():
        return None
    process = target.GetProcess()
    if not process or not process.IsValid():
        return None
    thread = process.GetSelectedThread()
    if not thread or not thread.IsValid():
        return None
    frame = thread.GetSelectedFrame()
    if not frame or not frame.IsValid():
        return None
    return frame


def _print(result, text=""):
    print(text, file=result)


def _run_command(debugger, command):
    command_result = lldb.SBCommandReturnObject()
    debugger.GetCommandInterpreter().HandleCommand(command, command_result)
    return command_result


def _print_command_result(result, command_result):
    output = command_result.GetOutput()
    error = command_result.GetError()
    if output:
        _print(result, output.rstrip())
    if error:
        _print(result, error.rstrip())


def _file_spec_path(file_spec):
    if not file_spec or not file_spec.IsValid():
        return None

    path = getattr(file_spec, "fullpath", None)
    if path:
        return path

    directory = file_spec.GetDirectory()
    filename = file_spec.GetFilename()
    if directory and filename:
        return os.path.join(directory, filename)
    if filename:
        return filename
    return None


def _current_source_location(debugger):
    frame = _selected_frame(debugger)
    if frame is None:
        return None, None

    line_entry = frame.GetLineEntry()
    file_spec = line_entry.GetFileSpec()
    if not file_spec or not file_spec.IsValid() or line_entry.GetLine() == 0:
        return None, None

    return _file_spec_path(file_spec), line_entry.GetLine()


def _normalize_condition(command):
    condition = command.strip()
    if not condition:
        return ""

    if re.search(r"==|!=|<=|>=|<|>", condition):
        return condition

    match = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)", condition)
    if match:
        return f"{match.group(1)} == {match.group(2).strip()}"

    return condition


def ctx(debugger, command, result, internal_dict):
    """Show the selected frame, nearby source, and local variables."""
    args = shlex.split(command)
    count = args[0] if args else "12"
    frame = _selected_frame(debugger)
    if frame is None:
        _print(result, "No selected frame. Run the process or select a stopped frame first.")
        return

    line_entry = frame.GetLineEntry()
    file_spec = line_entry.GetFileSpec()
    path = _file_spec_path(file_spec)
    line = line_entry.GetLine()
    function = frame.GetFunctionName() or "<unknown>"

    _print(result, f"{function} at {path or '<unknown>'}:{line}")
    debugger.HandleCommand(f"source list --count {count}")
    debugger.HandleCommand("frame variable --show-types")


def cbt(debugger, command, result, internal_dict):
    """Show a compact backtrace with frame numbers, functions, and file locations."""
    target = debugger.GetSelectedTarget()
    process = target.GetProcess() if target and target.IsValid() else None
    thread = process.GetSelectedThread() if process and process.IsValid() else None
    if not thread or not thread.IsValid():
        _print(result, "No selected thread.")
        return

    for frame in thread:
        line_entry = frame.GetLineEntry()
        file_spec = line_entry.GetFileSpec()
        path = file_spec.GetFilename() if file_spec and file_spec.IsValid() else "?"
        line = line_entry.GetLine()
        function = frame.GetFunctionName() or "?"
        _print(result, f"#{frame.GetFrameID():<2} {function}  {path}:{line}")


def bmain(debugger, command, result, internal_dict):
    """Set a breakpoint on main."""
    debugger.HandleCommand("breakpoint set --name main")


def rehearse(debugger, command, result, internal_dict):
    """Print a short LLDB practice menu for the current session."""
    _print(result, "LLDB reps:")
    _print(result, "  bfn function_name   set breakpoint by function")
    _print(result, "  rr                  launch again")
    _print(result, "  n / s / so          next, step in, step out")
    _print(result, "  ctx                 source + locals at the selected frame")
    _print(result, "  cbt                 compact backtrace")
    _print(result, "  loopskip i=37       continue until this line has i == 37")
    _print(result, "  loopbreak 80        run until line 80")
    _print(result, "  locals              typed locals")
    _print(result, "  display value       print value every time execution stops")
    _print(result, "  expr -- value       evaluate an expression")
    _print(result, "  memory read addr    inspect memory")
    _print(result, "  apropos keyword     discover commands by topic")


def reload_lldbinit(debugger, command, result, internal_dict):
    """Reload ~/.lldbinit after editing aliases or scripts."""
    debugger.HandleCommand("command source ~/.lldbinit")
    _print(result, f"Reloaded ~/.lldbinit at {time.strftime('%H:%M:%S')}")


def target_paths(debugger, command, result, internal_dict):
    """Print the target executable, launch cwd, and current source file."""
    target = debugger.GetSelectedTarget()
    if not target or not target.IsValid():
        _print(result, "No selected target.")
        return

    exe = _file_spec_path(target.GetExecutable()) or "<unknown>"
    launch_info = target.GetLaunchInfo()
    cwd = launch_info.GetWorkingDirectory() or os.getcwd()
    _print(result, f"exe: {exe}")
    _print(result, f"cwd: {cwd}")

    frame = _selected_frame(debugger)
    if frame:
        line_entry = frame.GetLineEntry()
        file_spec = line_entry.GetFileSpec()
        path = _file_spec_path(file_spec)
        if path:
            _print(result, f"src: {path}:{line_entry.GetLine()}")


def loopskip(debugger, command, result, internal_dict):
    """Continue until the current source line is reached with a condition true."""
    condition = _normalize_condition(command)
    if not condition:
        _print(result, "Usage: loopskip i=37")
        return

    path, line = _current_source_location(debugger)
    if path is None:
        _print(result, "No source line selected. Stop inside a running program first.")
        return

    cmd = (
        "breakpoint set --one-shot true "
        f"--file {shlex.quote(path)} --line {line} "
        f"--condition {shlex.quote(condition)}"
    )
    breakpoint_result = _run_command(debugger, cmd)
    if not breakpoint_result.Succeeded():
        _print(result, "Could not set loopskip breakpoint:")
        _print_command_result(result, breakpoint_result)
        return

    _print_command_result(result, breakpoint_result)
    _print(result, f"Continuing until {os.path.basename(path)}:{line} where {condition}")
    continue_result = _run_command(debugger, "continue")
    if not continue_result.Succeeded():
        _print(result, "Could not continue:")
        _print_command_result(result, continue_result)


def lookskip(debugger, command, result, internal_dict):
    """Compatibility alias for loopskip."""
    loopskip(debugger, command, result, internal_dict)


def loopbreak(debugger, command, result, internal_dict):
    """Run naturally until a line, typically the first line after a loop."""
    args = shlex.split(command)
    if len(args) != 1 or not args[0].isdigit():
        _print(result, "Usage: loopbreak <line>")
        return

    if _selected_frame(debugger) is None:
        _print(result, "No selected frame. Stop inside a running program first.")
        return

    _print(result, f"Running until line {args[0]}")
    until_result = _run_command(debugger, f"thread until {args[0]}")
    if not until_result.Succeeded():
        _print(result, "Could not run until that line:")
        _print_command_result(result, until_result)


def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f lldbutils.ctx ctx -h "Show source context and locals"')
    debugger.HandleCommand('command script add -f lldbutils.cbt cbt -h "Compact backtrace"')
    debugger.HandleCommand('command script add -f lldbutils.bmain bmain -h "Breakpoint on main"')
    debugger.HandleCommand('command script add -f lldbutils.rehearse rehearse -h "Practice menu for common LLDB moves"')
    debugger.HandleCommand('command script add -f lldbutils.reload_lldbinit reload_lldbinit -h "Reload ~/.lldbinit"')
    debugger.HandleCommand('command script add -f lldbutils.target_paths target_paths -h "Show target paths"')
    debugger.HandleCommand('command script add -f lldbutils.loopskip loopskip -h "Continue until current loop line matches a condition"')
    debugger.HandleCommand('command script add -f lldbutils.lookskip lookskip -h "Alias for loopskip"')
    debugger.HandleCommand('command script add -f lldbutils.loopbreak loopbreak -h "Run until a line after a loop"')
