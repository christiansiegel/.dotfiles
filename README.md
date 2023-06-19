# .dotfiles

## Setup

1. Clone this repo
    ```sh
    git clone git@github.com:christiansiegel/.dotfiles.git ~/.dotfiles
    ```
1. Install [rcm][]
    ```sh
    sudo apt install rcm -y
    # or
    brew install rcm
    ```
1. Link the rcm config only
    ```sh
    rcup -v rcrc
    ```
1. Dry run to see which files will be symlinked
    ```sh
    lsrc
    ```
1. Link the dotfiles
    ```sh
    rcup -v
    ```
1. Install ZSH
    ```sh
    sudo apt install zsh -y
    chsh -s $(which zsh)
    ```
1. Install [zsh-syntax-highlighting][]
    ```sh
    sudo apt install zsh-syntax-highlighting -y
    # or
    brew install zsh-syntax-highlighting
    ```
1. Install [pure][]
    ```sh
    git clone https://github.com/sindresorhus/pure.git ~/.zsh-pure
    ```
1. Install znazzy terminal theme (e.g. for iTerm2: https://github.com/sindresorhus/iterm2-snazzy)

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