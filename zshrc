# Shared shell configuration. Put machine-specific settings in ~/.zshrc.local.
# That optional file loads after shared settings; keep it outside Git (see README.md).

# Resolve this file at load time so help works from any directory or symlink.
typeset -g _dotfiles_config=${${(%):-%x}:A}

# Use # @topic to group commands, and # @doc immediately before each definition.
# @topic Dotfiles
# @doc Show an overview; use -h for all aliases and functions.
function dotfiles() {
  if (( $# == 0 )); then
    print -rl -- 'Dotfiles' '' \
      '  cddot          Open the dotfiles repository.' \
      '  zsh_reload     Apply local shell configuration changes to this shell.' \
      '  pull_dotfiles  Pull updates, force relinking, and reload the shell.' \
      '  push_dotfiles  Stage all changes, commit as update, and push.' \
      '  dotfiles -h    List all aliases and functions with descriptions.'
    return
  fi

  if (( $# > 1 )) || [[ $1 != -h && $1 != --help ]]; then
    print -u2 -r -- 'Usage: dotfiles [-h|--help]'
    return 2
  fi

  print -r -- 'Usage: dotfiles [-h|--help]'
  print -rl -- '' 'Commands defined in your dotfiles:'
  command awk '
    BEGIN { topic = "Other" }
    /^# @topic / {
      topic = substr($0, 10)
      description = ""
      next
    }
    /^# @doc / {
      description = substr($0, 8)
      next
    }
    /^alias / || /^function / {
      name = $0
      sub(/^(alias|function) +/, "", name)
      sub(/[=( ].*$/, "", name)
      if (!(topic in seen)) {
        seen[topic] = 1
        topics[++count] = topic
      }
      commands[topic] = commands[topic] sprintf("  %-18s %s\n", name, description ? description : "(undocumented)")
    }
    { description = "" }
    END {
      for (i = 1; i <= count; i++) {
        topic = topics[i]
        printf "\n%s\n%s", topic, commands[topic]
      }
    }
  ' "$_dotfiles_config"
}

# @topic Shell
# @doc Reload the shell configuration.
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

# @doc Show shell history with timestamps.
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

# @topic Git
# Git falls back to EDITOR unless a Git-specific editor is configured.

# @doc Run Git.
alias g='git'
# @doc Stage selected files.
alias ga='git add'
# @doc Stage all changes, including new and deleted files.
alias gaa='git add --all'
# @doc Stage changes to tracked files.
alias gau='git add --update'
# @doc Stage changes interactively by patch.
alias gap='git add --patch'
# @doc List or manage branches.
alias gb='git branch'
# @doc Cherry-pick commits.
alias gcp='git cherry-pick'
# @doc Resolve a revision and cherry-pick its commit.
function gcpb() {
  local commit
  commit=$(command git rev-parse --verify --end-of-options "${1:?usage: gcpb <revision>}^{commit}") || return
  command git cherry-pick "$commit"
}
# @doc Abort a cherry-pick.
alias gcpa='git cherry-pick --abort'
# @doc Continue a cherry-pick.
alias gcpc='git cherry-pick --continue'
# @doc Commit with the staged diff shown in the editor.
alias gc='git commit --verbose'
# @doc Amend the last commit and edit its message.
alias gc!='git commit --verbose --amend'
# @doc Amend the last commit without editing its message.
alias gcn!='git commit --verbose --no-edit --amend'
# @doc Commit with a message supplied as an argument.
alias gcm='git commit --verbose --message'
# @doc Check out a branch, commit, or file.
alias gco='git checkout'
# @doc Switch to the local default branch without fetching.
alias gcom='git checkout "$(git_main_branch)"'

# @doc Fetch the default branch without tags, fast-forward it, and switch to it.
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
# @doc Create and check out a branch.
alias gcob='git checkout -b'
# @doc Show unstaged changes.
alias gd='git diff'
# @doc Diff against the local default branch.
alias gdm='git diff "$(git_main_branch)"'
# @doc Show staged changes.
alias gdca='git diff --cached'
# @doc Show a compact commit graph.
alias gl='git log --graph --oneline --decorate'
# @doc Show a compact commit graph across all refs.
alias gla='git log --graph --oneline --decorate --all'
# @doc Pull and rebase onto upstream without automatic tag fetching.
alias gpr='git pull --rebase --no-tags'
# @doc Push the current branch to origin.
alias gpo='git push origin "$(current_branch)"'
# @doc Rebase the current branch.
alias grb='git rebase'
# @doc Abort a rebase.
alias grba='git rebase --abort'
# @doc Continue a rebase.
alias grbc='git rebase --continue'
# @doc Start an interactive rebase.
alias grbi='git rebase --interactive'
# @doc Interactively rebase onto the local default branch.
alias grbim='git rebase --interactive "$(git_main_branch)"'
# @doc Fetch the default branch without tags and interactively rebase onto origin.
function grbiom() {
  local base
  base=$(git_main_branch) || return
  command git fetch --no-tags origin "refs/heads/${base}:refs/remotes/origin/$base" || return
  command git rebase --interactive "origin/$base"
}
# @doc Reset commits or staged changes; accepts Git reset options.
alias gr='git reset'
# @doc DESTRUCTIVE: hard reset; discard tracked changes.
alias gr!='git reset --hard'

# @doc DESTRUCTIVE: discard tracked changes and delete untracked files/dirs; keep ignored files.
function gclean() (
  cdgr || return
  command git reset --hard HEAD &&
    command git clean -fd
)
# @doc Show full Git status.
alias gs='git status'
# @doc Show short status without untracked files or ahead/behind counts.
alias gsf='git status -sb -uno --no-ahead-behind'

# @doc Change to the repository root.
function cdgr() {
  local root
  root=$(git_repo_root) || return
  builtin cd -- "$root"
}

# @doc Print the current branch name.
function current_branch() {
  command git rev-parse --abbrev-ref HEAD
}

# @doc Print the default branch, preferring origin then upstream.
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

# @doc Print the repository root directory.
function git_repo_root() {
  command git rev-parse --show-toplevel
}

# @topic Arcanist
# @doc Create or update an Arcanist diff.
alias ard='arc diff'
# @doc Create or update an Arcanist diff with autoland.
alias arda='arc diff --autoland'
# @doc Create or update an Arcanist diff without unit tests.
alias ardnu='arc diff --nounit'
# @doc Land changes with Arcanist.
alias arl='arc land'
# @doc Run arc tidy.
alias art='arc tidy'
# @doc Run arc flow.
alias arf='arc flow'

# @topic Bazel
# @doc Run all Bazel tests beneath the current package.
alias bt='bazel test ...'
# @doc Run Bazel tests without cached test results.
alias btnc='bazel test --cache_test_results=no ...'

# @topic Gazelle
# @doc Run Gazelle.
alias gz='gazelle'
# @doc Run Gazelle, stage BUILD.bazel files, and commit them.
alias gzc='gazelle && (cdgr && git add "**/BUILD.bazel") && git commit -m "gazelle"'

# @topic Dotfiles
# @doc Change to the dotfiles repository.
alias cddot='cd "$HOME/.dotfiles"'
# @doc Stage all dotfile changes, commit as update, and push.
alias push_dotfiles='(cddot && gaa && gcm update && gpo)'
# @doc Pull dotfiles, force relinking, and reload the shell configuration.
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
