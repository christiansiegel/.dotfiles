# .dotfiles

## Setup

### Install dependencies

On Debian/Ubuntu:

```sh
sudo apt update
sudo apt install git curl make vim zsh rcm zsh-syntax-highlighting
```

On macOS, install [Homebrew][] first, then:

```sh
brew install git rcm zsh-syntax-highlighting
```

macOS includes Zsh, Vim, and curl. The validation command also requires Make;
install Apple's Command Line Tools with `xcode-select --install` if needed.
The shell configuration supports both Apple Silicon and Intel Homebrew paths.

### Link the configuration

1. Clone this repo (requires GitHub SSH access):
    ```sh
    git clone git@github.com:christiansiegel/.dotfiles.git ~/.dotfiles
    ```
1. Install [Pure][] (optional):
    ```sh
    git clone https://github.com/sindresorhus/pure.git ~/.zsh-pure
    ```
1. Link the [rcm][] config only:
    ```sh
    rcup -v rcrc
    ```
1. Preview which files will be symlinked:
    ```sh
    lsrc
    ```
1. Link the dotfiles:
    ```sh
    rcup -v
    ```
1. On Linux, select Zsh as your login shell if needed:
    ```sh
    chsh -s "$(command -v zsh)"
    ```
    On macOS, the default login shell is already Zsh on a fresh account.
1. Open a new terminal, or start Zsh with `zsh`.

Pure and [zsh-syntax-highlighting][] are optional; startup skips them when
not installed. For a matching terminal color scheme, optionally install
[Snazzy](https://github.com/sindresorhus/iterm2-snazzy).

### Xfce Terminal colors (Linux)

Apply the official [Catppuccin Mocha preset](https://github.com/catppuccin/xfce4-terminal)
from an Xfce desktop session (requires `curl` and `xfconf-query`):

```sh
sh ~/.dotfiles/scripts/apply-terminal-theme.sh
```

The script applies the preset through `xfconf-query`, including foreground,
background, cursor, selection, and the 16-color palette. It disables desktop
theme colors so the palette takes effect. Other terminal preferences are kept.
You can also select **Catppuccin-Mocha** in Terminal Preferences → Colors → Presets.
The script downloads the preset if missing and reuses it on later runs. It is
stored in `$XDG_DATA_HOME/xfce4/terminal/colorschemes`, defaulting to
`~/.local/share/xfce4/terminal/colorschemes`.

### tmux status bar colors

`rcup -v` links `tmux.conf` to `~/.tmux.conf`. It applies Catppuccin Mocha
colors to the status bar and highlights the active window in mauve. New tmux
servers load it automatically. Reload it in an existing tmux session with:

```sh
tmux source-file ~/.tmux.conf
```

### Optional Node.js setup

The shared configuration loads [NVM][] from `~/.config/nvm` on Linux and
macOS. For a fresh installation, clone a release into that exact directory:

```sh
mkdir -p "$HOME/.config"
git clone --branch v0.40.8 --depth 1 https://github.com/nvm-sh/nvm.git "$HOME/.config/nvm"
```

This follows NVM's Git installation approach and does not modify the linked
`.zshrc`. If NVM is already installed elsewhere, it must be made available at
`~/.config/nvm` for this configuration to load it.

In Zsh, load NVM and install a default Node.js LTS version:

```zsh
export NVM_DIR="$HOME/.config/nvm"
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
```

Check the installation with `command -v nvm`, `node --version`, and
`npm --version`. New shells load NVM automatically when it is installed.

## Machine-specific settings

Put settings that vary between machines in `~/.zshrc.local`. The shared
`.zshrc` loads this optional file after shared settings, so it can override them.
Keep it outside this repository and do not add it with `mkrc`.

For example, select a machine-specific Kubernetes configuration:

```zsh
export KUBECONFIG="$HOME/.kube/uconfig"
```

Without a local override, Kubernetes uses its normal configuration lookup.
Machine-specific executable directories can also be added to `PATH` here.

Set `EDITOR` here to choose an editor for this machine. Git uses it unless
`GIT_EDITOR` or Git's `core.editor` selects a different editor. Arcanist's
editor is configured automatically after this file loads, using the final
`EDITOR` value. This setup still runs each time a shell starts.

## Validation

Run `make check` from this repository before committing shell changes.
It requires Zsh and Make, checks shell syntax, and loads the configuration
twice with a temporary home to check startup and reload without personal
plugins, NVM, or local overrides. System-installed plugins can still load.
Arcanist is stubbed during validation to avoid changing its configuration.

## Adding new files to the project

```sh
mkrc ~/<DOT_FILENAME>

# Example
mkrc ~/.zshrc
```

See also [rcm tutorial][]

Note: The original file will be deleted and symlinked from `~/.dotfiles` back to its original location.

[rcm]: https://github.com/thoughtbot/rcm
[rcm tutorial]: http://thoughtbot.github.io/rcm/rcm.7.html
[pure]: https://github.com/sindresorhus/pure
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
[Homebrew]: https://brew.sh/
[NVM]: https://github.com/nvm-sh/nvm#installing-and-updating
