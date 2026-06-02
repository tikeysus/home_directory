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

`debug` builds C and C++ targets with debug symbols and no optimization:

```sh
clang/clang++ -g -O0 -fno-omit-frame-pointer
```

Open an existing executable:

```sh
debug ./program -- arg1 arg2
```

## Cheat Sheet

### First Moves

| Command | Use |
| --- | --- |
| `rehearse` | Print a short practice menu inside LLDB. |
| `bmain` | Set a breakpoint on `main`. |
| `rr` | Relaunch the current target. |
| `so` | Step out of the current function. Same idea as `finish`. |
| `reload_lldbinit` | Reload aliases and Python commands after editing `~/.lldbinit`. |

Example:

```lldb
(lldb) bmain
(lldb) rr
(lldb) ctx
```

### Context And Stack

| Command | Use |
| --- | --- |
| `ctx` | Show current function, nearby source, and typed locals. |
| `cbt` | Show a compact backtrace for the selected thread. |
| `btall` | Show backtraces for all threads. |
| `fs 2` | Select frame 2. |
| `up1` / `down1` | Move up or down one stack frame. |
| `locals` | Show local variables with types. |
| `target_paths` | Show executable, launch working directory, and current source path. |

Example:

```lldb
(lldb) cbt
(lldb) fs 2
(lldb) ctx
```

### Breakpoints

| Command | Use |
| --- | --- |
| `bfn name` | Break on function `name`. |
| `bl` | List breakpoints. |
| `bd 1` | Delete breakpoint 1. With no id, delete all breakpoints. |
| `bdis 1` | Disable breakpoint 1. |
| `ben 1` | Enable breakpoint 1. |

Example:

```lldb
(lldb) bfn my_function
(lldb) bl
(lldb) rr
```

### Loop Navigation

| Command | Use |
| --- | --- |
| `loopskip i=37` | From the current source line, continue until that same line is reached with `i == 37`. |
| `lookskip i=37` | Same as `loopskip`; kept as a compatibility alias. |
| `loopbreak 80` | Run naturally until line 80, usually the first line after a loop. |

Example:

```lldb
(lldb) ctx
(lldb) loopskip i=37
(lldb) ctx
```

`loopskip` also accepts full conditions:

```lldb
(lldb) loopskip i > 100
(lldb) loopskip count == target
```

If an ordinary breakpoint is still enabled on the same line, LLDB may stop on that breakpoint before the `loopskip` condition is reached. Disable or delete that breakpoint first with `bdis <id>` or `bd <id>`.

### Inspection

| Command | Use |
| --- | --- |
| `regs` | Read registers. |
| `disf` | Disassemble the selected frame. |
| `im symbol` | Look up a symbol or address in loaded images. |
| `symtab` | Dump target module symbol tables. |
| `ptype expr` | Evaluate an expression and show its type. |

Example:

```lldb
(lldb) locals
(lldb) ptype my_value
(lldb) disf
```

### Memory

| Command | Use |
| --- | --- |
| `xw 8 addr` | Read 8 four-byte words at `addr`, formatted as hex. |
| `xg 8 addr` | Read 8 eight-byte words at `addr`, formatted as hex. |

Example:

```lldb
(lldb) p &buffer[0]
(lldb) xw 16 0x000000016fdff120
```

### Watch-Style Displays

These are built-in LLDB commands worth remembering alongside the custom aliases:

| Command | Use |
| --- | --- |
| `display expr` | Print `expr` every time execution stops. This is closest to a debugger watch panel. |
| `undisplay 1` | Stop displaying expression 1. |
| `target stop-hook list` | List display/stop hooks. |
| `watchpoint set variable name` | Stop when variable `name` is written. |
| `watchpoint list` | List watchpoints. |
| `watchpoint delete 1` | Delete watchpoint 1. |

Example:

```lldb
(lldb) display i
(lldb) display total
(lldb) n
(lldb) n
(lldb) undisplay 1
```

## Git Cheat Sheet

These aliases live in `home/.zshrc`, which should be linked to `~/.zshrc`.

### Daily Flow

| Command | Use |
| --- | --- |
| `status` | Show the current branch and short working tree status. |
| `add file` | Stage specific files. |
| `aa` | Stage all changes in the repo. |
| `commit "message"` | Commit staged changes with a message. |
| `amend` | Amend the last commit. |
| `pull` | Pull using the current branch's configured upstream. |
| `pullbranch` | Pull the current branch explicitly from `origin`. |
| `push` | Push the current branch to `origin` and set upstream. |

Example:

```sh
status
add src/app.js
commit "Add project dashboard"
push
```

### Branches

| Command | Use |
| --- | --- |
| `branch` | List local branches. |
| `branches` | List local and remote branches. |
| `switch name` | Switch to an existing branch. |
| `newbranch name` | Create and switch to a new branch. |
| `deletebranch name` | Delete a merged local branch. |
| `force-deletebranch name` | Delete a local branch even if it is unmerged. |

Example:

```sh
fetch
newbranch feature/payment-flow
```

### Sync And Review

| Command | Use |
| --- | --- |
| `fetch` | Fetch all remotes and prune deleted remote branches. |
| `remotes` | Show configured remotes. |
| `log` | Show a compact graph of all branches. |
| `last` | Show the latest commit with changed files. |
| `diff` | Show unstaged changes. |
| `staged` | Show staged changes. |
| `showcommit hash` | Inspect a commit. |

Example:

```sh
fetch
log
staged
```

### Merge And Rebase

| Command | Use |
| --- | --- |
| `merge branch` | Merge another branch into the current branch. |
| `rebase branch` | Rebase the current branch onto another branch. |
| `rebasemain` | Fetch and rebase onto `origin/main`. |
| `rebasemaster` | Fetch and rebase onto `origin/master`. |
| `abortmerge` | Abort an in-progress merge. |
| `abortrebase` | Abort an in-progress rebase. |
| `continuerebase` | Continue a rebase after resolving conflicts. |

Example:

```sh
fetch
rebasemain
continuerebase
```

### Stash And Cleanup

| Command | Use |
| --- | --- |
| `stash "message"` | Save local changes with a message. |
| `stashlist` | List saved stashes. |
| `popstash` | Apply and remove the latest stash. |
| `unstage file` | Remove a file from the staged set. |
| `discard file` | Discard local changes to a file. |
| `cleanbranches` | Prune deleted remote-tracking branches. |

Example:

```sh
stash "wip before rebase"
rebasemain
popstash
```

## Personal Commands

- `rehearse`: print a short practice menu.
- `ctx`: show selected frame, nearby source, and typed locals.
- `cbt`: compact backtrace.
- `bmain`: set a breakpoint on `main`.
- `loopskip i=37`: from the current source line, continue until that same line is reached with `i == 37`.
- `loopbreak <line>`: run naturally until the given line, typically the first line after a loop.
- `lookskip i=37`: compatibility alias for `loopskip`.
- `target_paths`: show executable, working directory, and current source path.
- `reload_lldbinit`: reload `~/.lldbinit` after editing it.

## Personal Aliases

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
