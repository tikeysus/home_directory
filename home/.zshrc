export PATH="$HOME/bin:$PATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_dups hist_ignore_space

autoload -Uz compinit
compinit

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
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
