export GOPRIVATE=github.tools.sap
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

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
export OLLAMA_HOST=127.0.0.1:11435
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

# aliases
alias fim='nvim $(fzf -m --preview="bat --color=always {}")'
alias ls='eza --color=auto'
alias pbcopy="xclip -sel clip"
alias pbpaste="xclip -o -sel clip"

# funcs
# yazi
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# work with secrets
function run_secrets() {
    types=('read' 'add')
    selected_type=$(printf "%s\n" "${types[@]}" | fzf)
    if [[ -z $selected_type ]]; then
        exit 0
    fi
    if [[ $selected_type == "read" ]]; then
        read_secret $@
    else
        add_secret $@
    fi
}

# read secrets
function read_secret() {
    _zsh_highlight() {}

    notes=$HOME/notes/keys/
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(eza --no-quotes $notes/"$opt" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    folder=$notes/"$opt"/"$note_name"
    fullapth="$folder"/secret.gpg
    masterkey=$(gpg --decrypt --no-symkey-cache "${notes}"master.gpg 2>/dev/null)

    value=$(gpg --decrypt --batch --yes --no-symkey-cache --passphrase $masterkey "$fullapth" 2>/dev/null)
    types=('buffer' 'stdout')
    selected_type=$(printf "%s\n" "${types[@]}" | fzf)
    if [[ -z $selected_type ]]; then
        exit 0
    fi
    if [[ $selected_type == "buffer" ]]; then
        echo "$value" | pbcopy
    else
        echo "$value"
    fi
}

# add secret
function add_secret() {
    _zsh_highlight() {}
    if [[ ! -t 0 ]]; then
        value=$(</dev/stdin)
    elif [[ $# -gt 0 ]]; then
        value="$1"
    else
        types=('buffer' 'manual')
        selected_type=$(printf "%s\n" "${types[@]}" | fzf)
        if [[ -z $selected_type ]]; then
            exit 0
        fi
        if [[ $selected_type == "buffer" ]]; then
            value=$(pbpaste)
        else
            echo "Enter secret value: "
            read -s value
        fi
    fi

    notes=$HOME/notes/keys/
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    current_date=$(date "+%Y.%m.%d")
    current_time=$(date "+%H:%M:%S")

    echo "Enter key name: "
    read note_name </dev/tty

    masterkey=$(gpg --decrypt --no-symkey-cache ${notes}master.gpg 2>/dev/null)
    folder=$notes/"$opt"/"$current_date"_"$current_time"_"$note_name"
    fullapth="$folder"/secret.gpg
    mkdir -p "$folder"
    echo "$value" | gpg --symmetric --no-symkey-cache --batch --passphrase "$masterkey" >"$fullapth"

    if [[ $? -eq 0 ]]; then
        sync_notes
        disown
    else
        rm $fullapth
    fi
}

# run notes
function run_remarks() {
    types=('read' 'add')
    selected_type=$(printf "%s\n" "${types[@]}" | fzf)
    if [[ -z $selected_type ]]; then
        exit 0
    fi
    if [[ $selected_type == "read" ]]; then
        open_remark $@
    else
        new_remark $@
    fi
}

# new note
function new_remark() {
    _zsh_highlight() {}
    notes=$HOME/notes/remarks/
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d  -printf "%f\n" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    current_date=$(date "+%Y.%m.%d")
    current_time=$(date "+%H:%M:%S")

    echo "Enter remark name: "
    read note_name

    folder=$notes/"$opt"/"$current_date"_"$current_time"_"$note_name"
    mkdir -p $folder
    fullapth="$folder"/note.md
    touch $fullapth
    echo "# ${note_name}" >> "$fullapth"
    echo "## ${current_date} ${current_time}" >> "$fullapth"
    echo " " >> "$fullapth"
    echo "\`\`\`text" >> "$fullapth"
    echo "\`\`\`" >> "$fullapth"

    nvim $fullapth

    if [[ $? -eq 0 ]]; then
        sync_notes
        disown
    else
        rm $fullapth
    fi
}

# open note
function open_remark() {
    _zsh_highlight() {}
    notes=$HOME/notes/remarks
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d  -printf "%f\n" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(eza --no-quotes $notes/"$opt" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi
    folder=$notes/"$opt"/"$note_name"
    fullapth="$folder"/note.md
    nvim "$fullapth"
}

# sync all notes
function sync_notes() {
	rclone sync --progress $HOME/notes/ ggld_e:notes
	if ! command -v ntfy &>/dev/null; then
		echo "synced"
	else
		ntfy send "Notes synced"
	fi
}

# git clone and add to tmux session
function tmuxgtcl() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: tmuxgtcl <repository-url> <session-name>"
    return 1
  fi


  local repo_url=$1
  local session_name=$2
  local repo_name=$(basename -s .git "$repo_url")
  local target_folder="$HOME/projects/$session_name/$repo_name"

  if [ -d "$target_folder" ]; then
    echo "$target_folder does exist."
    return 0
  fi

  # Clone the repository to the target folder
  git clone "$repo_url" "$target_folder"

  # Check if tmux session exists
  tmux has-session -t "$session_name" 2>/dev/null
  if [ $? != 0 ]; then
      # Create new tmux session
      tmux new-session -d -s "$session_name" -c "$target_folder" -n "$repo_name"
  else
      # Open a new window in the existing or new session
      tmux new-window -t "$session_name" -n "$repo_name" -c "$target_folder"
  fi
  #
  # Attach to the session
  tmux attach -t "$session_name"
}

# tmuxgtcl for list
function tmuxgtcl_list() {
  cat "$1" |
    while read in; do
        tmuxgtcl "$in" "$2"
    done
}


