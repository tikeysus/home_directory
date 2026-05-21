"""Small personal LLDB commands loaded from ~/.lldbinit."""

import os
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
    path = file_spec.GetPath() if file_spec and file_spec.IsValid() else None
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
    _print(result, "  bfl file.c 42       set breakpoint by file and line")
    _print(result, "  bfn function_name   set breakpoint by function")
    _print(result, "  rr                  launch again")
    _print(result, "  n / s / finish      next, step in, step out")
    _print(result, "  ctx                 source + locals at the selected frame")
    _print(result, "  cbt                 compact backtrace")
    _print(result, "  locals              typed locals")
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

    exe = target.GetExecutable().GetPath()
    launch_info = target.GetLaunchInfo()
    cwd = launch_info.GetWorkingDirectory() or os.getcwd()
    _print(result, f"exe: {exe}")
    _print(result, f"cwd: {cwd}")

    frame = _selected_frame(debugger)
    if frame:
        line_entry = frame.GetLineEntry()
        file_spec = line_entry.GetFileSpec()
        if file_spec and file_spec.IsValid():
            _print(result, f"src: {file_spec.GetPath()}:{line_entry.GetLine()}")


def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f lldbutils.ctx ctx -h "Show source context and locals"')
    debugger.HandleCommand('command script add -f lldbutils.cbt cbt -h "Compact backtrace"')
    debugger.HandleCommand('command script add -f lldbutils.bmain bmain -h "Breakpoint on main"')
    debugger.HandleCommand('command script add -f lldbutils.rehearse rehearse -h "Practice menu for common LLDB moves"')
    debugger.HandleCommand('command script add -f lldbutils.reload_lldbinit reload_lldbinit -h "Reload ~/.lldbinit"')
    debugger.HandleCommand('command script add -f lldbutils.target_paths target_paths -h "Show target paths"')
