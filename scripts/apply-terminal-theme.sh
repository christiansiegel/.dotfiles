#!/bin/sh
set -eu

theme_dir="${XDG_DATA_HOME:-$HOME/.local/share}/xfce4/terminal/colorschemes"
theme="$theme_dir/catppuccin-mocha.theme"

if ! command -v xfconf-query >/dev/null 2>&1; then
    printf '%s\n' 'This script requires Xfce Terminal and xfconf-query.' >&2
    exit 1
fi

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
        https://raw.githubusercontent.com/catppuccin/xfce4-terminal/main/themes/catppuccin-mocha.theme \
        -o "$download"
    mv "$download" "$theme"
    trap - EXIT HUP INT TERM
fi

set_property() {
    if xfconf-query -c xfce4-terminal -p "$1" >/dev/null 2>&1; then
        xfconf-query -c xfce4-terminal -p "$1" -s "$3"
    else
        xfconf-query -c xfce4-terminal -p "$1" -n -t "$2" -s "$3"
    fi
}

# Xfce's active settings live in xfconf; apply only the preset's color keys.
while IFS='=' read -r key value; do
    case "$key" in
        Color*|TabActivityColor)
            property=$(printf '%s' "$key" | sed 's/\([a-z]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')
            case "$value" in
                TRUE|FALSE)
                    type=bool
                    value=$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')
                    ;;
                *) type=string ;;
            esac
            set_property "/$property" "$type" "$value"
            ;;
    esac
done < "$theme"
set_property /color-use-theme bool false

printf '%s\n' 'Applied Catppuccin Mocha to Xfce Terminal.'
