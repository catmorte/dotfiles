# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
#
export TERM=xterm-256color
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# Linux version of OSX pbcopy and pbpaste.
alias pbcopy="xclip -sel clip"
alias pbpaste="xclip -o -sel clip"

source ~/Repos/zsh-autocomplete/zsh-autocomplete.plugin.zsh

plugins=(git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-npm-scripts-autocomplete
)
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source $ZSH/oh-my-zsh.sh
[ -f ~/.config/lf/LF_ICONS ] && {
    LF_ICONS="$(tr '\n' ':' <~/.config/lf/LF_ICONS)" \
        && export LF_ICONS
}
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Download Znap, if it's not there yet.
[[ -r ~/Repos/znap/znap.zsh ]] ||
git clone --depth 1 -- \
    https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh  # Start Znap
SHOW_MAN="/home/rssl/scripts/fzf_man.sh"
if [ -f "$SHOW_MAN" ]; then
    source "$SHOW_MAN" --source-only
fi
RUN_NOTE="/home/rssl/scripts/run_notes.sh"
if [ -f "$RUN_NOTE" ]; then
    source "$RUN_NOTE" --source-only
fi
RUN_SECRET="/home/rssl/scripts/run_secrets.sh"
if [ -f "$RUN_SECRET" ]; then
    source "$RUN_SECRET" --source-only
fi
READ_SECRET="/home/rssl/scripts/read_secret.sh"
if [ -f "$READ_SECRET" ]; then
    source "$READ_SECRET" --source-only
fi
ADD_SECRET="/home/rssl/scripts/add_secret.sh"
if [ -f "$ADD_SECRET" ]; then
    source "$ADD_SECRET" --source-only
fi
SYNC_NOTES="/home/rssl/scripts/sync_notes.sh"
if [ -f "$SYNC_NOTES" ]; then
    source "$SYNC_NOTES" --source-only
fi
NEW_NOTE="/home/rssl/scripts/new_note.sh"
if [ -f "$NEW_NOTE" ]; then
    source "$NEW_NOTE" --source-only
fi
OPEN_NOTE="/home/rssl/scripts/open_note.sh"
if [ -f "$OPEN_NOTE" ]; then
    source "$OPEN_NOTE" --source-only
fi
LFCD="/home/rssl/.config/lf/lfcd.sh"
if [ -f "$LFCD" ]; then
    source "$LFCD"
fi
FSTASH="/home/rssl/scripts/fstash.sh"
if [ -f "$FSTASH" ]; then
    source "$FSTASH"
fi

function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}


alias fim='nvim $(fzf -m --preview="bat --color=always {}")'
bindkey -s '^o' 'yy\n'
bindkey -s '^i' 'show_man\n'
bindkey -s '^e' 'fim\n'
bindkey -s '^a' 'tmux attach\n'
bindkey -s '^n' 'run_notes\n'
bindkey -s '^p' 'run_secrets\n'
# bindkey -s '^H' 'cd ~\n'
bindkey -s '^w' 'nohup /home/rssl/scripts/sync_notes.sh >/dev/null 2>&1 & disown\n'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
LF_ICONS=$(sed /home/rssl/.config/lf/icons \
        -e '/^[ \t]*#/d'       \
        -e '/^[ \t]*$/d'       \
        -e 's/[ \t]\+/=/g'     \
    -e 's/$/ /')
LF_ICONS=${LF_ICONS//$'\n'/:}
export LF_ICONS
eval "$(starship init zsh)"
export PATH="$PATH:$(go env GOPATH)/bin"


export LESS="-R -q"
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

alias ls='exa --color=auto'
zstyle ':completion:*' insert-tab false
export GOPRIVATE=github.tools.sap
. "$HOME/.cargo/env"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="/home/rssl/anaconda3/bin:$PATH"
export NVM_DIR="$HOME/.config/nvm"
export PATH="$HOME/flutter/flutter/bin:$PATH"
export PATH="$HOME/development/flutter/bin:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme
#
# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source <(fzf --zsh)
eval "$(thefuck --alias)"
