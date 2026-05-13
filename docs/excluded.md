# Excluded From Version Control

These existed on the machine but were intentionally not copied into the repo:

- `~/.ssh/known_hosts*`: generated host fingerprints.
- `~/.ssh/id_*`: private/public SSH key material.
- shell and REPL histories such as `~/.zsh_history`, `~/.python_history`, `~/.lesshst`, and `~/.viminfo`.
- generated shell caches such as `~/.zcompdump*` and `~/.zsh_sessions/`.
- VS Code `globalStorage`, `workspaceStorage`, SQLite state databases, backups, and `mcp.json`.
- application caches under `~/.cache`, package caches, and large application state directories.

If one of these ever needs to become reproducible, prefer a documented setup step or a redacted template rather than committing the live file.
