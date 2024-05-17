# custom zsh configuration

> !NOTE: include the below in your `/etc/zsh/zshenv` (systemwide) or `~/.zshenv` (user) to configure your zsh to look for configuration files in the `~/.config/zsh` directory.

```bash
if [[ -z "$XDG_CONFIG_HOME" ]] 
then
	export XDG_CONFIG_HOME="$HOME/.config/"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]] 
then
	export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi
```

## Pre-Install

- [NerdFonts](https://www.nerdfonts.com/font-downloads) - Font should be **MONO Type** for terminal compatibility

## To change the prompt styles

```bash
p10k configure
```
