# home_directory

Personal home-directory setup: dotfiles, editor settings, package manifests, and bootstrap scripts for getting a Mac into a familiar development shape.

## Layout

```text
.
├── home/                  # Files that map directly into $HOME
│   ├── .zshrc
│   ├── .zprofile
│   ├── .gitconfig
│   ├── .vimrc
│   ├── bin/
│   ├── .ssh/config
│   └── .config/
├── config/                # App configs outside $HOME dotfile paths
│   ├── iterm2/
│   ├── vscode/User/
│   └── claude/            # Claude Code: CLAUDE.md, settings, keybindings, hooks
├── packages/              # Reinstall manifests and package snapshots
│   ├── Brewfile
│   ├── homebrew/
│   ├── vscode/extensions.txt
│   └── cargo/installed.txt
├── scripts/               # Idempotent setup helpers
└── docs/                  # Notes about manual setup and excluded files
```

## Quick Start

From this repo:

```sh
./scripts/link-home.sh
./scripts/link-app-configs.sh
./scripts/install-packages.sh
./scripts/install-vscode-extensions.sh
./scripts/restore-iterm2.sh
```

## Updating This Repo

When your local environment changes, refresh the tracked snapshot from this machine:

```sh
make snapshot
```

This updates Homebrew, Cargo, VS Code extensions, VS Code settings/keybindings, and iTerm2 preferences, then validates the tracked files and prints the git diff/status.

Common flow:

```sh
brew install foo
make snapshot
git diff
make snapshot-commit
```

After iTerm2 or VS Code settings change, use the same `make snapshot` flow. For ordinary dotfile edits, edit the files in this repo directly and commit normally.

If the snapshot looks good and you want one command to commit and push it:

```sh
make snapshot-push
```

`link-home.sh` symlinks every file under `home/` into the matching location under `$HOME`. If a real file already exists, it is moved aside with a timestamped `.backup-*` suffix before the symlink is created.

`link-app-configs.sh` links app-specific files that live outside normal dotfile paths, currently VS Code user settings and keybindings.

`install-packages.sh` installs Homebrew if needed, restores packages from `packages/Brewfile`, and installs Cargo tools from `packages/cargo/installed.txt`. The Brewfile is the main Homebrew restore manifest. `packages/homebrew/` keeps snapshot details such as installed formula versions, casks, taps, leaves, services, and `brew config`.

`snapshot.sh` refreshes package manifests from the current machine, including Homebrew, VS Code, and Cargo snapshots.

`restore-iterm2.sh` imports the tracked iTerm2 preference plist. Quit iTerm2 first if you want the restore to be clean.

Note: files like `.zshrc` and `.vimrc` are hidden dotfiles. Use `ls -la home` to see them in the repo.

## What Belongs Here

- Shell config: zsh profile, aliases, functions, prompt/tool integration.
- Git config: global Git preferences and ignores.
- Editors: Vim, Emacs, VS Code settings, keybindings, snippets, and extension lists.
- Package manifests: Homebrew, VS Code extensions, and Cargo-installed tools.
- Language/tool config: Rust, Python, Docker, terminal, window manager, and other deliberate config.
- Setup scripts: repeatable, safe-to-rerun commands for a fresh machine.

## What Should Stay Out

- API keys, tokens, private SSH keys, browser profiles, and app databases.
- Shell history, editor history, caches, compiled files, and generated state.
- Machine-only files that do not make sense on a fresh install.

Use `*.local` files or a `local/` directory for private machine-specific overrides.

## Claude Code Notes

`config/claude/` tracks the user-level Claude Code configuration from `~/.claude/`:

- `CLAUDE.md` — global user preferences and behavior overrides
- `settings.json` — theme, effort level, and hook wiring
- `settings.local.json` — per-machine tool permission allowlist
- `keybindings.json` — keyboard binding overrides
- `hooks/auto-stage.js` — PostToolUse hook: auto-stages files after Edit/Write
- `hooks/block-dangerous-commands.js` — PreToolUse hook: blocks dangerous Bash patterns

`link-app-configs.sh` creates symlinks from `~/.claude/` to the tracked repo files. `snapshot.sh` copies the current state back into the repo. Not tracked: skills and plugins (marketplace-managed), runtime state (cache, sessions, history, daemon files).

## Shell Notes

The tracked `.zshrc` is plain zsh: path setup, history, completion, aliases, colorized `ls`, standalone `zsh-syntax-highlighting`, and optional Powerlevel10k loading from `~/powerlevel10k`.

Powerlevel10k prompt settings live in tracked `.p10k.zsh` and include the current directory plus Git status when inside a repository.
