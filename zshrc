# Shared shell configuration. Put machine-specific settings in ~/.zshrc.local.
# That optional file loads after shared settings; keep it outside Git (see README.md).

# zsh
alias zsh_reload='source "$HOME/.zshrc"'

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

export EDITOR=vim

# Keep executable and function search paths unique when reloading.
typeset -U path fpath

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history

alias h='history -i'

autoload -Uz compinit
compinit

# pure theme
if [[ -r "$HOME/.zsh-pure/prompt_pure_setup" ]]; then
  fpath+=("$HOME/.zsh-pure")
  autoload -Uz promptinit
  promptinit
  prompt pure
fi

# zsh-syntax-highlighting
for syntax_highlighting_file in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [[ -r "$syntax_highlighting_file" ]]; then
    source "$syntax_highlighting_file"
    break
  fi
done
unset syntax_highlighting_file

# git
# Git falls back to EDITOR unless a Git-specific editor is configured.

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gau='git add --update'
alias gap='git add --patch'
alias gb='git branch'
alias gcp='git cherry-pick'
function gcpb() {
  local commit
  commit=$(command git rev-parse --verify --end-of-options "${1:?usage: gcpb <revision>}^{commit}") || return
  command git cherry-pick "$commit"
}
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gcn!='git commit --verbose --no-edit --amend'
alias gcm='git commit --verbose --message'
alias gco='git checkout'
alias gcom='git checkout "$(git_main_branch)"'

# Update only origin's default branch, then switch directly to its latest state.
function gcomu() {
  local base current
  base=$(git_main_branch) || return
  current=$(command git symbolic-ref --quiet --short HEAD)

  if [[ "$current" == "$base" ]]; then
    command git fetch --no-tags origin "refs/heads/${base}:refs/remotes/origin/$base" || return
    if ! command git merge-base --is-ancestor HEAD "refs/remotes/origin/$base"; then
      print -u2 -r -- "Local $base has commits not on origin/$base; leaving it unchanged."
      return 1
    fi
    command git merge --ff-only "refs/remotes/origin/$base"
  elif command git show-ref -q --verify "refs/heads/$base"; then
    command git fetch --no-tags origin "refs/heads/${base}:refs/heads/$base" || return
    command git switch "$base"
  else
    command git fetch --no-tags origin "refs/heads/${base}:refs/remotes/origin/$base" || return
    command git switch --track -c "$base" "origin/$base"
  fi
}
alias gcob='git checkout -b'
alias gd='git diff'
alias gdm='git diff "$(git_main_branch)"'
alias gdca='git diff --cached'
alias gl='git log --graph --oneline --decorate'
alias gla='git log --graph --oneline --decorate --all'
alias gpr='git pull --rebase --no-tags'
alias gpo='git push origin "$(current_branch)"'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbim='git rebase --interactive "$(git_main_branch)"'
function grbiom() {
  local base
  base=$(git_main_branch) || return
  command git fetch --no-tags origin "refs/heads/${base}:refs/remotes/origin/$base" || return
  command git rebase --interactive "origin/$base"
}
alias gr='git reset'
alias gr!='git reset --hard'
alias gs='git status'
alias gsf='git status -sb -uno --no-ahead-behind'

function cdgr() {
  local root
  root=$(git_repo_root) || return
  builtin cd -- "$root"
}

function current_branch() {
  command git rev-parse --abbrev-ref HEAD
}

function git_main_branch() {
  local remote ref
  # Resolve and verify the remote default in one Git call on the common path.
  for remote in origin upstream; do
    ref=$(command git rev-parse --verify --symbolic-full-name "refs/remotes/$remote/HEAD" 2>/dev/null) || continue
    if [[ -n "$ref" && "$ref" != "refs/remotes/$remote/HEAD" ]]; then
      print -r -- "${ref#refs/remotes/$remote/}"
      return
    fi
  done
  command git rev-parse --git-dir &>/dev/null || return
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,master,trunk}; do
    if command git show-ref -q --verify "$ref"; then
      print -r -- "${ref:t}"
      return
    fi
  done
  print -r -- main
}

function git_repo_root() {
  command git rev-parse --show-toplevel
}

# arcanist
alias ard='arc diff'
alias arda='arc diff --autoland'
alias ardnu='arc diff --nounit'
alias arl='arc land'
alias art='arc tidy'
alias arf='arc flow'

# bazel
alias bt='bazel test ...'
alias btnc='bazel test --cache_test_results=no ...'

# gazelle
alias gz='gazelle'
alias gzc='gazelle && (cdgr && git add "**/BUILD.bazel") && git commit -m "gazelle"'

# dotfiles
alias cddot='cd "$HOME/.dotfiles"'
alias push_dotfiles='(cddot && gaa && gcm update && gpo)'
alias pull_dotfiles='(cddot && gcom && gpr) && (cd "$HOME" && rcup -vf rcrc && rcup -vf) && zsh_reload'

# nvm
export NVM_DIR="$HOME/.config/nvm"
if [[ -r "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
if [[ -r "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi

# user-installed executables
if [[ -r "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

# machine-specific settings
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

# Apply the final editor choice after machine-specific overrides.
if command -v arc &>/dev/null; then
  arc set-config editor "$EDITOR" >/dev/null
fi
