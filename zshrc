# zsh
alias zsh_reload='source "$HOME/.zshrc"'

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

EDITOR=vim

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history

alias h='history -i'

autoload -Uz compinit
compinit

# pure theme
fpath+=("$HOME/.zsh-pure")
autoload -U promptinit; promptinit
prompt pure

# zsh-syntax-highlighting
if [[ $OSTYPE == 'darwin'* ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# git
GIT_EDITOR=VIM

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gau='git add --update'
alias gap='git add --patch'
alias gb='git branch'
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
alias gdm='git diff $(git_main_branch)'
alias gdca='git diff --cached'
alias gl='git log --graph --oneline --decorate'
alias gla='git log --graph --oneline --decorate --all'
alias gpr='git pull --rebase'
alias gpo='git push origin $(current_branch)'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbim='git rebase --interactive $(git_main_branch)'
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
if command -v arc &> /dev/null; then
  arc set-config editor vim > /dev/null
fi

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
alias gzc='gazelle && (cd $(git_repo_root) && git add "**/BUILD.bazel") && git commit -m "gazelle"'

# dotfiles
alias cddot='cd $HOME/.dotfiles'
alias push_dotfiles='(cddot && gaa && gcm update && gpo)'
alias pull_dotfiles='(cddot && gcom && gpr) && (cd $HOME && rcup -vf rcrc && rcup -vf) && zsh_reload'

# path
[[ -d /home/user/go-repos/bin ]] && export PATH="/home/user/go-repos/bin:$PATH"

# k8s
export KUBECONFIG=~/.kube/uconfig
