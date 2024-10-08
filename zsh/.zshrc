export TERM=xterm-256color
autoload edit-command-line

ZSH_THEME="robbyrussell"
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000



plugins=(git dotenv zsh-syntax-highlighting zsh-autosuggestions zsh-npm-scripts-autocomplete zsh-autocomplete)

zstyle ':completion:*' insert-tab false
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zle -N edit-command-line

# tools
source <(fzf --zsh)
source $ZSH/oh-my-zsh.sh
source "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
eval "$(starship init zsh)"
eval "$(thefuck --alias)"

# bindings
bindkey '^Xe' edit-command-line
bindkey -s '^o' 'yy\n'
bindkey -s '^a' 'tmux attach\n'
bindkey -s '^o' 'yy\n'
bindkey -s '^e' 'fim\n'
bindkey -s '^a' 'tmux attach\n'
bindkey -s '^n' 'run_remarks\n'
bindkey -s '^p' 'run_secrets\n'
bindkey -s '^w' 'sync_notes\n'
bindkey -s '^i' 'run_api\n'
bindkey -s '^o' 'yy\n'
case 'uname' in
  Darwin)

  ;;
  Linux)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ;;
esac

