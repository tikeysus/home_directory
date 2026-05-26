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
│   ├── .emacs.d/
│   ├── .ssh/config
│   ├── .stack/
│   └── .config/
├── config/                # App configs outside $HOME dotfile paths
│   ├── iterm2/
│   └── vscode/User/
├── packages/              # Reinstall manifests and package snapshots
│   ├── Brewfile
│   ├── homebrew/
│   ├── vscode/extensions.txt
│   ├── npm/global-packages.txt
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
./scripts/install-oh-my-zsh.sh
./scripts/install-vscode-extensions.sh
./scripts/restore-iterm2.sh
```

`link-home.sh` symlinks every file under `home/` into the matching location under `$HOME`. If a real file already exists, it is moved aside with a timestamped `.backup-*` suffix before the symlink is created.

`link-app-configs.sh` links app-specific files that live outside normal dotfile paths, currently VS Code user settings and keybindings.

`install-packages.sh` installs Homebrew if needed, restores packages from `packages/Brewfile`, installs global npm packages from `packages/npm/global-packages.txt`, and installs Cargo tools from `packages/cargo/installed.txt`. The Brewfile is the main Homebrew restore manifest. `packages/homebrew/` keeps snapshot details such as installed formula versions, casks, taps, leaves, services, and `brew config`.

`snapshot.sh` refreshes package manifests from the current machine, including Homebrew, VS Code, npm, and Cargo snapshots.

`restore-iterm2.sh` imports the tracked iTerm2 preference plist. Quit iTerm2 first if you want the restore to be clean.

Note: files like `.zshrc` and `.vimrc` are hidden dotfiles. Use `ls -la home` to see them in the repo.

## What Belongs Here

- Shell config: zsh profile, aliases, functions, prompt/tool integration.
- Git config: global Git preferences and ignores.
- Editors: Vim, Emacs, VS Code settings, keybindings, snippets, and extension lists.
- Package manifests: Homebrew, VS Code extensions, npm globals, Cargo-installed tools.
- Language/tool config: Cabal, Stack, Rust, Python, Docker, terminal, window manager, and other deliberate config.
- Setup scripts: repeatable, safe-to-rerun commands for a fresh machine.

## What Should Stay Out

- API keys, tokens, private SSH keys, browser profiles, and app databases.
- Shell history, editor history, caches, compiled files, and generated state.
- Machine-only files that do not make sense on a fresh install.

Use `*.local` files or a `local/` directory for private machine-specific overrides.

## Shell Notes

The tracked `.zshrc` uses Oh My Zsh with these custom plugins:

- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

Run `./scripts/install-oh-my-zsh.sh` before opening a new zsh session on a fresh machine.
