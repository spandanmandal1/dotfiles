export ZDOTDIR="$HOME/.config/zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config//zsh//.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load alias,options if exsits
[ -f "${ZDOTDIR}/aliasrc" ] && source "${ZDOTDIR}/aliasrc"
[ -f "${ZDOTDIR}/optionrc" ] && source "${ZDOTDIR}/optionrc"

# Load completions
# Completion files for Nix-installed tools (pass, kubectl, gh, ...)
fpath=("$HOME/.nix-profile/share/zsh/site-functions" $fpath)
# Dump lives in the cache: ZDOTDIR is a read-only Nix store link.
# No -C, so the dump is rebuilt when completion files are added or removed.
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Plugins come from Nix (home.packages in home.nix)
plugins="$HOME/.nix-profile/share"
source "$plugins/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"
source "$plugins/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
source "$plugins/zsh/site-functions/F-Sy-H.plugin.zsh"
source "$plugins/fzf-tab/fzf-tab.plugin.zsh"

# End of lines added by compinstall
source "$plugins/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme"
unset plugins

# To customize prompt, run `p10k configure` or edit ~/.config//zsh//.p10k.zsh.
#[[ ! -f ~/.config//zsh//.p10k.zsh ]] || source ~/.config//zsh//.p10k.zsh
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# Keybindings
bindkey -e
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down

# History
HISTSIZE=5000
HISTFILE=~/.local/share/zsh/history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
bindkey '^R' fzf-history-widget

# The following lines were added by compinstall
# zstyle :compinstall filename '/home/spandan/.zshrc'

# Open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line


export PATH="$HOME/.local/bin:$PATH"
