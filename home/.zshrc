export PATH="$HOME/bin:$PATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_dups hist_ignore_space

autoload -Uz compinit
compinit
zstyle ":completion:*" matcher-list \
  "m:{a-zA-Z}={A-Za-z}" \
  "m:{a-zA-Z}={A-Za-z} r:|[-_.]=* r:|=*" \
  "m:{a-zA-Z}={A-Za-z} l:|=* r:|=*"
zstyle ":completion:*" menu select
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v gls >/dev/null 2>&1; then
  export LS_COLORS="di=01;34:ln=01;36:so=01;35:pi=33:ex=01;32:*.c=00;36:*.h=00;36:*.cpp=00;36:*.hpp=00;35:*.sh=01;32:*.zsh=01;32:*.py=01;32:*.rs=00;33:*.md=00;35:*.json=00;33:*.txt=00;37"

  ls() {
    if [[ -t 1 ]]; then
      command gls -C --color=always "$@" | sed -E $'s/(^|[[:space:]])(\\.[^[:space:]\033]+)/\\1\033[2;37m\\2\033[0m/g'
      return "$pipestatus[1]"
    fi

    command gls --color=auto "$@"
  }
else
  export CLICOLOR=1
  export LSCOLORS="ExGxFxDxCxegedabagacad"
  alias ls="ls -G"
fi

alias la="ls -A"
alias ll="ls -lah"

# Git aliases
alias add="git add"
alias aa="git add ."
alias commit="git commit -m"
alias amend="git commit --amend"
alias status="git status --short --branch"
alias pull="git pull"
alias clone="git clone"

push() {
  local branch
  branch="$(git branch --show-current)" || return 1

  if [[ -z "$branch" ]]; then
    echo "Not currently on a branch."
    return 1
  fi

  git push -u origin "$branch"
}

pullbranch() {
  local branch
  branch="$(git branch --show-current)" || return 1

  if [[ -z "$branch" ]]; then
    echo "Not currently on a branch."
    return 1
  fi

  git pull origin "$branch"
}

alias c="claude"
alias branch="git branch"
alias branches="git branch -a"
alias checkout="git checkout"
alias switch="git switch"
alias newbranch="git switch -c"
alias deletebranch="git branch -d"
alias force-deletebranch="git branch -D"

alias fetch="git fetch --all --prune"
alias remotes="git remote -v"

alias merge="git merge"
alias rebase="git rebase"
alias rebasemain="git fetch origin && git rebase origin/main"
alias rebasemaster="git fetch origin && git rebase origin/master"
alias abortmerge="git merge --abort"
alias abortrebase="git rebase --abort"
alias continuerebase="git rebase --continue"

alias log="git log --oneline --decorate --graph --all"
alias last="git log -1 --stat"
alias diff="git diff"
alias staged="git diff --staged"
alias showcommit="git show"

alias stash="git stash push -m"
alias stashlist="git stash list"
alias popstash="git stash pop"

alias unstage="git restore --staged"
alias discard="git restore"
alias cleanbranches="git fetch --prune"
lcnew() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Not inside a git repo"
    return 1
  }

  "$root/scripts/new" "$@"
}
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

if [[ -r "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
  [[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
else
  autoload -Uz vcs_info
  zstyle ":vcs_info:*" enable git
  zstyle ":vcs_info:git:*" check-for-changes true
  zstyle ":vcs_info:git:*" stagedstr "+"
  zstyle ":vcs_info:git:*" unstagedstr "*"
  zstyle ":vcs_info:git:*" formats " %F{magenta}%b%f%F{yellow}%u%c%f"
  zstyle ":vcs_info:git:*" actionformats " %F{magenta}%b|%a%f%F{yellow}%u%c%f"

  precmd() {
    vcs_info
  }

  setopt prompt_subst
  PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '
fi

typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[alias]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=red,bold"

for zsh_autosuggest in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [[ -r "$zsh_autosuggest" ]]; then
    source "$zsh_autosuggest"
    break
  fi
done
unset zsh_autosuggest

for zsh_highlight in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [[ -r "$zsh_highlight" ]]; then
    source "$zsh_highlight"
    break
  fi
done
unset zsh_highlight
