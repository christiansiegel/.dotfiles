#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
check_home=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-check.XXXXXX")
trap 'rm -rf "$check_home"' EXIT
trap 'exit 1' HUP INT TERM

# Use a temporary home so personal plugins, NVM, and local overrides are absent.
# Stub Arcanist so validation cannot rewrite the user's configuration.
if output=$(HOME="$check_home" ZDOTDIR="$check_home" XDG_CONFIG_HOME="$check_home/.config" \
  zsh -f -c '
    arc() { return 0; }
    source "$1" || exit
    source "$1" || exit
    dotfiles --help >/dev/null || exit
  ' check "$repo_dir/zshrc" 2>&1); then
  if [ -n "$output" ]; then
    printf '%s\n' "$output" >&2
    exit 1
  fi
else
  printf '%s\n' "$output" >&2
  exit 1
fi

printf '%s\n' 'Shell startup and reload passed with an isolated home.'
