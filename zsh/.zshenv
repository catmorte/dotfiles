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

# utility funcs for further usage
function select_dir() {
    local title=$1
    local pth=$2
    local selection=$(find "$pth" -maxdepth 1 -mindepth 1 -type d  -printf "%f\n" | fzf --border=rounded --height 20 --prompt="$title" --layout=reverse)
    if [[ -z "$selection"  ]]; then
        echo "nothing selected"
        exit 1
    fi
    printf "$selection"
}

function select_files() {
    local title=$1
    local pth=$2
    local selection=$(find "$pth" -maxdepth 1 -mindepth 1  -printf "%f\n" | fzf -m --border=rounded --height 20 --prompt="$title" --layout=reverse)
    if [[ -z "$selection" ]]; then
        echo "nothing selected"
        exit 1
    fi
    printf "$selection"
}

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
    selected_type=$(printf "%s\n" "${types[@]}" | fzf --border=rounded --height 20 --prompt="Select option: " --layout=reverse)
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
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | fzf --border=rounded --height 20 --prompt="Select space: " --layout=reverse)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(eza --no-quotes $notes/"$opt" | fzf --border=rounded --height 20 --prompt="Select secret: " --layout=reverse)
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
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | fzf --border=rounded --height 20 --prompt="Select space: " --layout=reverse)
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
    selected_type=$(printf "%s\n" "${types[@]}" | fzf --border=rounded --height 20 --prompt="Select option: " --layout=reverse)
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
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d  -printf "%f\n" | fzf --border=rounded --height 20 --prompt="Select space: " --layout=reverse)
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
    cat <<EOF >> $fullapth
    # ${note_name}
    ## ${current_date} ${current_time}

    ```text

    ```
EOF

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
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d  -printf "%f\n" | fzf --border=rounded --height 20 --prompt="Select space: " --layout=reverse)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(eza --no-quotes $notes/"$opt" | fzf --border=rounded --height 20 --prompt="Select remark: " --layout=reverse)
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

# api
function new_api() {
    _zsh_highlight() {}
    local spaces=$HOME/notes/apis/

    echo "Enter api name: "
    read api_name

    local folder=$spaces/"$API_SPACE"/api/"$api_name"
    mkdir -p $folder
    mkdir -p $folder/requests/default
    mkdir -p $folder/responses/default

    echo "Content-Type: application/json" > "$folder"/requests/default/headers
    echo '{}' > "$folder"/requests/default/body

    cat <<EOF >> $folder/before.sh
# save history
DIR=\$(dirname "\$0")
DT="\$(date +%s)"
mv "\$DIR/responses/\$NAME/body" "\$DIR/responses/\$NAME/\$DT.response"
mv "\$DIR/responses/\$NAME/headers" "\$DIR/responses/\$NAME/\$DT.headers"
# do stuff
# varValue=\$(jq -r '.value' < \$DIR/../<API_NAME>/responses/\$NAME/body)
# sed "s/{{var}}/\$varValue/g" "\$DIR/requests/\$NAME/body.template" > "\$DIR/requests/\$NAME/body"
# sed "s/{{var}}/\$token/g" "\$DIR/requests/\$NAME/headers.template" > "\$DIR/requests/\$NAME/headers"
EOF

    cat <<EOF >> $folder/after.sh
EOF

    cat <<EOF >> $folder/script.sh
#!/bin/bash
DIR=\$(dirname "\$0")
/bin/bash \$DIR/before.sh
METHOD=<SET METHOD>
URL=<SET URL>

curl -X \$METHOD \\
  --header @"\$DIR/requests/\$NAME/headers" \\
  -d @"\$DIR/requests/\$NAME/body" \\
  -o "\$DIR/responses/\$NAME/body" \\
  -D "\$DIR/responses/\$NAME/headers" \\
  "\$URL"

/bin/bash \$DIR/after.sh
EOF
    
    chmod +x "$folder"/before.sh
    chmod +x "$folder"/after.sh
    chmod +x "$folder"/script.sh


    nvim "$folder"/script.sh

    if [[ $? -eq 0 ]]; then
        sync_notes
        disown
    else
        rm -r $folder
    fi
}

function run_api() {
    local types=('call api' 'switch space and environment' 'add space' 'add environment' 'add vars to environment' 'add api' 'add case name')
    local selected_type=$(printf "%s\n" "${types[@]}" | fzf --border=rounded --height 20 --prompt="Select option: " --layout=reverse)
    if [[ -z $selected_type ]]; then
        exit 0
    fi
    if [[ $selected_type == "call api" ]]; then
        _zsh_highlight() {}
        local apis=$HOME/notes/apis/$API_SPACE/api
        local api=$(select_dir "Select api to call: " $apis)

        local names=$apis/"$api"/requests
        local name=$(select_dir "Select case name: " $names)

        echo "Call $api, for $name name"

        local vars=$HOME/notes/apis/$space/envs/$API_ENV
        local varsToUse=$(select_files "Select vars (TAB to select multiple): " $vars)

        printf $varsToUse
        local lines=("${(f)varsToUse}")
        for line in "${lines[@]}";do
            echo "$vars/$line"
            source "$vars/$line"
        done

        NAME=$name /bin/bash $apis/$api/script.sh
        nvim $apis/$api/responses/$name/body $apis/$api/responses/$name/headers
    elif [[ $selected_type == "switch space and environment" ]]; then
        _zsh_highlight() {}
        local spaces=$HOME/notes/apis/
        if ! space=$(select_dir "Select space: " "$spaces"); then; return; fi
        export API_SPACE=$space

        local envs=$HOME/notes/apis/$space/envs
        if ! env=$(select_dir "Select environment: " "$envs"); then; return; fi
        export API_ENV=$env
        echo "Use $space, for $env environment"
    elif [[ $selected_type == "add api" ]]; then
        _zsh_highlight() {}
        local spaces=$HOME/notes/apis/

        echo "Enter api name: "
        read api_name

        local folder=$spaces/"$API_SPACE"/api/"$api_name"
        mkdir -p $folder
        mkdir -p $folder/requests/default
        mkdir -p $folder/responses/default

        echo "Content-Type: application/json" > "$folder"/requests/default/headers
        echo '{}' > "$folder"/requests/default/body

        cat <<EOF >> $folder/before.sh
# save history
DIR=\$(dirname "\$0")
DT="\$(date +%s)"
mv "\$DIR/responses/\$NAME/body" "\$DIR/responses/\$NAME/\$DT.response"
mv "\$DIR/responses/\$NAME/headers" "\$DIR/responses/\$NAME/\$DT.headers"
# do stuff
# varValue=\$(jq -r '.value' < \$DIR/../<API_NAME>/responses/\$NAME/body)
# sed "s/{{var}}/\$varValue/g" "\$DIR/requests/\$NAME/body.template" > "\$DIR/requests/\$NAME/body"
# sed "s/{{var}}/\$token/g" "\$DIR/requests/\$NAME/headers.template" > "\$DIR/requests/\$NAME/headers"
EOF

    cat <<EOF >> $folder/after.sh
EOF

    cat <<EOF >> $folder/script.sh
#!/bin/bash
DIR=\$(dirname "\$0")
/bin/bash \$DIR/before.sh
METHOD=<SET METHOD>
URL=<SET URL>

curl -X \$METHOD \\
  --header @"\$DIR/requests/\$NAME/headers" \\
  -d @"\$DIR/requests/\$NAME/body" \\
  -o "\$DIR/responses/\$NAME/body" \\
  -D "\$DIR/responses/\$NAME/headers" \\
  "\$URL"

/bin/bash \$DIR/after.sh
EOF
    
    chmod +x "$folder"/before.sh
    chmod +x "$folder"/after.sh
    chmod +x "$folder"/script.sh

    nvim "$folder"/script.sh

    if [[ $? -eq 0 ]]; then
        sync_notes
        disown
    else
        rm -r $folder
    fi
    elif [[ $selected_type == "add case name" ]]; then
        local apis=$HOME/notes/apis/$API_SPACE/api
        local api=$(select_dir "Select api to which add new case: " $apis)
        echo "Enter case name: "
        read case_name
        mkdir -p $HOME/notes/apis/$API_SPACE/api/$api/requests/$case_name
        touch $HOME/notes/apis/$API_SPACE/api/$api/requests/$case_name/body
        touch $HOME/notes/apis/$API_SPACE/api/$api/requests/$case_name/headers
        nvim $HOME/notes/apis/$API_SPACE/api/$api/requests/$case_name/body $HOME/notes/apis/$API_SPACE/api/$api/requests/$case_name/headers
        if [[ $? -eq 0 ]]; then
            sync_notes
            disown
        else
            rm -r $HOME/notes/apis/$API_SPACE/envs/$env_name
        fi
    elif [[ $selected_type == "add space" ]]; then
        echo "Enter space name: "
        read space_name
        mkdir -p $HOME/notes/apis/$space_name
        mkdir -p $HOME/notes/apis/$space_name/envs
        mkdir -p $HOME/notes/apis/$space_name/api
        export API_SPACE=$space_name
        sync_notes
    elif [[ $selected_type == "add environment" ]]; then
        echo "Enter env name: "
        read env_name
        mkdir -p $HOME/notes/apis/$API_SPACE/envs/$env_name
        touch $HOME/notes/apis/$API_SPACE/envs/$env_name/base.env
        nvim $HOME/notes/apis/$API_SPACE/envs/$env_name/base.env
        if [[ $? -eq 0 ]]; then
            export API_ENV=$env_name
            sync_notes
            disown
        else
            rm -r $HOME/notes/apis/$API_SPACE/envs/$env_name
        fi
    elif [[ $selected_type == "add vars to environment" ]]; then
        echo "Enter env vars name (without .env): "
        read env_name
        touch $HOME/notes/apis/$API_SPACE/envs/$API_ENV/$env_name.env
        nvim $HOME/notes/apis/$API_SPACE/envs/$API_ENV/$env_name.env
        sync_notes
    fi
}

