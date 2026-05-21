# LLDB Setup

These files are linked by `scripts/link-home.sh`:

- `home/.lldbinit` -> `~/.lldbinit`
- `home/.lldb/lldbutils.py` -> `~/.lldb/lldbutils.py`
- `home/bin/debug` -> `~/bin/debug`

## macOS Permission Prompt

If macOS asks for permission every time LLDB starts or attaches:

```sh
sudo DevToolsSecurity -enable
sudo dscl . append /Groups/_developer GroupMembership "$(whoami)"
```

Then open System Settings -> Privacy & Security -> Developer Tools and enable your terminal app.

## Fast Start

Compile and open a C file in LLDB:

```sh
debug file.c
```

Compile and launch immediately:

```sh
debug --run file.c -- arg1 arg2
```

Only compile, useful for checking warnings:

```sh
debug --build-only file.cpp
```

Open an existing executable:

```sh
debug ./program -- arg1 arg2
```

## Personal Commands

- `rehearse`: print a short practice menu.
- `ctx`: show selected frame, nearby source, and typed locals.
- `cbt`: compact backtrace.
- `bmain`: set a breakpoint on `main`.
- `target_paths`: show executable, working directory, and current source path.
- `reload_lldbinit`: reload `~/.lldbinit` after editing it.

## Personal Aliases

- `bfl file.c 42`: breakpoint by file and line.
- `bfn name`: breakpoint by function name.
- `bl`, `bd`, `bdis`, `ben`: list, delete, disable, and enable breakpoints.
- `rr`: launch again.
- `fs 2`: select frame 2.
- `btall`: backtrace all threads.
- `locals`: show typed local variables.
- `regs`: read registers.
- `disf`: disassemble the selected frame.
- `symtab`: dump target module symbol tables.
- `xw 8 addr`, `xg 8 addr`: read memory as 32-bit or 64-bit hex words.
