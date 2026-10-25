#!/bin/sh
set -eu

theme_dir="${XDG_DATA_HOME:-$HOME/.local/share}/iterm2/colors"
theme="$theme_dir/catppuccin-mocha.itermcolors"

if [ ! -f "$theme" ]; then
    if ! command -v curl >/dev/null 2>&1; then
        printf '%s\n' 'Downloading the theme requires curl.' >&2
        exit 1
    fi
    mkdir -p "$theme_dir"
    download=$(mktemp "$theme_dir/.catppuccin-mocha.XXXXXX")
    trap 'rm -f "$download"' EXIT
    trap 'exit 1' HUP INT TERM
    curl -fSL --connect-timeout 10 --max-time 60 \
        https://raw.githubusercontent.com/catppuccin/iterm/main/colors/catppuccin-mocha.itermcolors \
        -o "$download"
    mv "$download" "$theme"
    trap - EXIT HUP INT TERM
fi

printf '%s\n' \
    'Catppuccin Mocha preset ready:' \
    "  $theme" \
    '' \
    'In iTerm2 Settings → Profiles → your profile → Colors → Color Presets:' \
    '1. Choose Import and select the file above (Cmd-Shift-G opens a path).' \
    '2. Choose catppuccin-mocha from Color Presets to apply it.'
