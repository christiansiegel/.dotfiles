# .dotfiles

## Setup

1. Clone this repo
    ```bash
    git clone git@github.com:christiansiegel/.dotfiles.git ~/.dotfiles
    ```
1. Install [rcm][]
    ```bash
    sudo apt install rcm -y
    ```
1. Link the rcm config only
    ```bash
    rcup -v rcrc
    ```
1. Dry run to see which files will be symlinked
    ```bash
    lsrc
    ```
1. Link the dotfiles
    ```bash
    rcup -v
    ```
1. Install ZSH
    ```bash
    sudo apt install zsh -y
    chsh -s $(which zsh)
    ```
1. Install [pure][]
    ```bash
    git clone https://github.com/sindresorhus/pure.git ~/.zsh-pure
    ```

## Adding new files to the project

```bash
mkrc ~/<DOT_FILENAME>

# Example
mkrc ~/.zshrc
```

See also [rcm tutorial][]

Note: The original file will be deleted and symlinked from `~/.dotfiles` back to its original location.

[rcm]: https://github.com/thoughtbot/rcm
[rcm tutorial]: http://thoughtbot.github.io/rcm/rcm.7.html
[pure]: https://github.com/sindresorhus/pure