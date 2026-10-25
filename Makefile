.PHONY: check

check:
	zsh -n zshrc
	sh -n scripts/check-zsh.sh
	sh -n scripts/install-iterm2-theme.sh
	sh scripts/check-zsh.sh
