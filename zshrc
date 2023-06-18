# zsh
alias zsh_reload='source ~/.zshrc'

# pure theme
fpath+=(~/.zsh-pure)
autoload -U promptinit; promptinit
prompt pure

# git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gau='git add --update'
alias gap='git add --patch'
alias gcp='git cherry-pick'
alias gcpb='git cherry-pick $(git rev-parse $1)'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gcn!='git commit --verbose --no-edit --amend'
alias gcm='git commit --verbose --message'
alias gco='git checkout'
alias gcom='git checkout $(git_main_branch)'
alias gcob='git checkout -b'
alias gd='git diff'
alias gdca='git diff --cached'
alias gl='git log --graph --oneline --decorate'
alias gla='git log --graph --oneline --decorate --all'
alias gpr='git pull --rebase'
alias gpo='git push origin $(current_branch)'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias gr='git reset'
alias gr!='git reset --hard'
alias gs='git status'

alias cdgr='cd $(git_repo_root)'

function current_branch() {
    command git rev-parse --abbrev-ref HEAD
}

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{master,trunk}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo main
}

function git_repo_root() {
    command git rev-parse --show-toplevel
}

# arcanist
alias ard='ard diff'
alias ardnu='arc diff --nounit'
alias arl='arc land'

# bazel
alias bt='bazel test ...'
alias btnc='bayel test --cache_test_results=no ...'

# gazelle
alias gz='gazelle'
alias gzc='gazelle && (cd $(git_repo_root) && git add **/*.BAZEL) && git commit -m "gazelle"'