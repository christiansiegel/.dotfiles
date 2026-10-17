.PHONY: check

check:
	zsh -n zshrc
	sh -n scripts/check-zsh.sh
	sh scripts/check-zsh.sh
