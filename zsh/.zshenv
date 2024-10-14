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
function select_option() {
    local prmt=$1
    shift
    local header=$1
    shift
    opts=("$@")
    local opt=$(printf "%s\n" "${opts[@]}" | fzf --border=rounded --height 20 --prompt="$prmt" --header="$header" --layout=reverse)
    if [[ -z $opt ]]; then
        exit 0
    fi
    printf "$opt"
}

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
    notes=$HOME/notes/keys/
    types=('READ' 'ADD' 'DELETE')
    local selected_type=$(select_option "Select option:" "" "${types[@]}")
    if [[ $selected_type == "READ" ]]; then
        _zsh_highlight() {}
        if ! opt=$(select_dir "Select space: " "$notes"); then; return; fi
        if ! note_name=$(select_files "Select secret: " "$notes/$opt"); then; return; fi
        folder=$notes/"$opt"/"$note_name"
        fullapth="$folder"/secret.gpg
        masterkey=$(gpg --decrypt --no-symkey-cache "${notes}"master.gpg 2>/dev/null)
        value=$(gpg --decrypt --batch --yes --no-symkey-cache --passphrase $masterkey "$fullapth" 2>/dev/null)
        types=('BUFFER' 'STDOUT')
        selected_type=$(printf "%s\n" "${types[@]}" | fzf)
        if [[ -z $selected_type ]]; then
            exit 0
        fi
        if [[ $selected_type == "BUFFER" ]]; then
            echo "$value" | pbcopy
        else
            echo "$value"
        fi

    elif [[ $selected_type == "ADD" ]]; then 
        _zsh_highlight() {}
        if [[ ! -t 0 ]]; then
            value=$(</dev/stdin)
        elif [[ $# -gt 0 ]]; then
            value="$1"
        else
            types=('BUFFER' 'MANUAL')
            selected_type=$(printf "%s\n" "${types[@]}" | fzf)
            if [[ -z $selected_type ]]; then
                exit 0
            fi
            if [[ $selected_type == "BUFFER" ]]; then
                value=$(pbpaste)
            else
                echo "Enter secret value: "
                read -s value
            fi
        fi

        if ! opt=$(select_dir "Select space: " "$notes"); then; return; fi

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
    elif [[ $selected_type == "DELETE" ]]; then 
        if ! opt=$(select_dir "Select space: " "$notes"); then; return; fi
        if ! note_name=$(select_files "Select secret: " "$notes/$opt"); then; return; fi
        rm -r -i  $notes/"$opt"/"$note_name"
    fi
}

# run notes
function run_remarks() {
    notes=$HOME/notes/remarks/
    types=('READ/UPDATE' 'ADD' 'DELETE')
    local selected_type=$(select_option "Select option:" "" "${types[@]}")
    if [[ $selected_type == "READ/UPDATE" ]]; then
        _zsh_highlight() {}
        if ! opt=$(select_dir "Select space: " "$notes"); then; return; fi

        note_name=$(eza --no-quotes $notes/"$opt" | fzf --border=rounded --height 20 --prompt="Select remark: " --layout=reverse)
        if [[ "$?" -ne 0 ]]; then
            return
        fi
        folder=$notes/"$opt"/"$note_name"
        fullapth="$folder"/note.md
        nvim "$fullapth"
    elif [[ $selected_type == "ADD" ]]; then 
        _zsh_highlight() {}
        if ! opt=$(select_dir "Select space: " "$notes"); then; return; fi

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
    elif [[ $selected_type == "DELETE" ]]; then 
        _zsh_highlight() {}
        if ! opt=$(select_dir "Select space: " "$notes"); then; return; fi

        note_name=$(eza --no-quotes $notes/"$opt" | fzf --border=rounded --height 20 --prompt="Select remark: " --layout=reverse)
        if [[ "$?" -ne 0 ]]; then
            return
        fi
        rm -r -i  $notes/"$opt"/"$note_name"
    fi
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

function run_api() {
    local root_api_path=$HOME/notes/apis/spaces/
    local root_templates_path=$HOME/notes/apis/templates/
    local root_stash_path=$HOME/notes/apis/stash/
    # NEW_SPACE
    function new_space_menu() {
        echo "SPACE'S NAME: "
        read space_name
        mkdir -p $root_api_path/$space_name
        mkdir -p $root_api_path/$space_name/envs
        mkdir -p $root_api_path/$space_name/api
        existing_space_menu "$space_name"
    }
    function new_stash_menu() {
        echo "STASH'S NAME: "
        read stash_name
        touch "$root_stash_path/$stash_name"
        cd "$root_stash_path/$stash_name" && nvim  
        existing_stash_menu "$stash_name"
    }
    function new_template_menu() {
        echo "TEMPLATE'S NAME: "
        read template_name
        mkdir -p "$root_templates_path/$template_name"
        mkdir -p "$root_templates_path/$template_name/.request_template"
        touch "$root_templates_path/$template_name/script.sh"
        touch "$root_templates_path/$template_name/before.sh"
        touch "$root_templates_path/$template_name/after.sh"
        touch "$root_templates_path/$template_name/init.sh"
        touch "$root_templates_path/$template_name/.request_template/init.sh"
        chmod +x "$root_templates_path/$template_name/script.sh"
        chmod +x "$root_templates_path/$template_name/before.sh"
        chmod +x "$root_templates_path/$template_name/after.sh"
        chmod +x "$root_templates_path/$template_name/init.sh"
        chmod +x "$root_templates_path/$template_name/.request_template/init.sh"
        cd "$root_templates_path/$template_name" && nvim  
        existing_template_menu "$template_name"
    }
    # SPACES/SN/ENVS/NEW_ENV
    function new_space_env_menu() {
        local space=$1
        echo "/$space: NEW ENV'S NAME: "
        read env_name
        mkdir -p "$envs/$env_name"
        touch "$envs/$env_name/base.env"
        cd "$envs/$env_name" && nvim "$envs/$env_name/base.env"
        existing_space_env_menu "$space" "$env_name"
    }
    # SPACES/SN/ENVS/EN/VARS/NEW_VAR
    function new_space_env_var_menu() {
        local space=$1
        local env=$2
        echo "/$space [$env]: NEW VAR'S NAME (W/O EXT): "
        read var_name
        touch $root_api_path/$space/envs/$env/$var_name.sh
        cd "$root_api_path/$space/envs/$env" && nvim $root_api_path/$space/envs/$env/$var_name.sh
        existing_space_env_vars_menu "$space" "$env" "$var_name.sh"
    }
    # SPACES/SN/APIS/NEW_API
    function new_space_api_menu() {
        local space=$1
        local env=$2
        echo "/$space [$env]: API'S NAME: "
        read api_name
        local existing=$(find "$root_templates_path" -maxdepth 1 -mindepth 1 -type d -printf "- %f\n")
        local opt=$(select_option "FROM TEMPLATE > " "/$space [$env]/APIS" "${existing[@]}")
        case "$opt" in
            *) [[ -n "$opt" ]] && {
                local template_name=$(echo "$opt" | sed 's/- //g')
                mkdir -p "$root_api_path/$space/api/$api_name"
                cp -ar "$root_templates_path/$template_name"/. "$root_api_path/$space/api/$api_name"
                mkdir -p "$root_api_path/$space/api/$api_name/requests/default"
                cp -ar "$root_templates_path/$template_name/.request_template"/. "$root_api_path/$space/api/$api_name/requests/default"
                echo "$template_name" > "$root_api_path/$space/api/$api_name/.template_name"
                cd "$root_api_path/$space/api/$api_name" && nvim
            } ;;
        esac

        existing_space_api_menu "$space" "$env" "$api_name"
    }
    # SPACES/SN/APIS/AN/REQUESTS/NEW_VAR
    function new_space_api_req_from_existing_menu() {
        local space=$1
        local env=$2
        local api=$3
        local existing=$(find "$root_api_path/$space/api/$api/requests" -maxdepth 1 -mindepth 1 -type d -printf "- %f\n")
        local opt=$(select_option "REQUESTS > " "/$space [$env]/APIS/$api/REQUESTS" "${existing[@]}")
        local existing_req=$(echo "$opt" | sed 's/- //g')
        echo "/$space [$env]/APIS/$api: NEW REQUESTS'S NAME: "
        read req_name
        local template_name=$(<"$root_api_path/$space/api/$api/.template_name")
        mkdir -p "$root_api_path/$space/api/$api_name/requests/$req_name"
        cp -r "$root_api_path/$space/api/$api/requests/$existing_req"/. "$root_api_path/$space/api/$api/requests/$req_name"
        existing_space_api_req_menu "$space" "$env" "$api" "$req_name"
    }
    # SPACES/SN/APIS/AN/REQUESTS/NEW_VAR
    function new_space_api_req_menu() {
        local space=$1
        local env=$2
        local api=$3
        echo "/$space [$env]/APIS/$api: NEW REQUESTS'S NAME: "
        read req_name
        local template_name=$(<"$root_api_path/$space/api/$api/.template_name")
        mkdir -p "$root_api_path/$space/api/$api_name/requests/$req_name"
        cp -r "$root_templates_path/$template_name/.request_template"/. "$root_api_path/$space/api/$api/requests/$req_name"
        existing_space_api_req_menu "$space" "$env" "$api" "$req_name"
    }
    # CALL
    function call_space_env_api_request() {
        local space=$1
        local env=$2
        local api=$3
        local req=$4
        local varsToUse=$(select_files "SELECT VARS (TAB FOR MULTI): " "$root_api_path/$space/envs/$env")
        local lines=("${(f)varsToUse}")
        for line in "${lines[@]}";do
            echo "$root_api_path/$space/envs/$env/$line"
            source "$root_api_path/$space/envs/$env/$line"
        done
        NAME=$req . "$root_api_path/$space/api/$api/script.sh"
    }
    # INIT API
    function init_space_env_api() {
        local space=$1
        local env=$2
        local api=$3
        . "$root_api_path/$space/api/$api/init.sh"
    }
    # INIT API REQ
    function init_space_env_api_req() {
        local space=$1
        local env=$2
        local api=$3
        local req=$4
        NAME=$req . "$root_api_path/$space/api/$api/requests/$req/init.sh"
    }
    # SPACES/SN/APIS/AN/REQUESTS/RN
    function existing_space_api_req_menu() {
        local space=$1
        local env=$2
        local api=$3
        local req=$4
        local options=( 'CALL' 'INIT REQUEST' 'UPDATE (NVIM)' '< BACK')
        local opt=$(select_option "OPTIONS > " "/$space [$env]/APIS/$api/REQUESTS/$req" "${options[@]}")
        case "$opt" in
            '< BACK') space_api_reqs_menu "$space" "$env" "$api" ;;
            'UPDATE (NVIM)') cd "$root_api_path/$space/api/$api/requests/$req" && nvim ;;
            'CALL') call_space_env_api_request "$space" "$env" "$api" "$req" ;;
            'INIT REQUEST') init_space_env_api_req "$space" "$env" "$api" "$req" 
        ;;
        esac
    }
    # SPACES/SN/APIS/AN/REQUESTS
    function space_api_reqs_menu() {
        local space=$1
        local env=$2
        local api=$3
        local options=('NEW' 'COPY EXISTING' '< BACK' )
        local existing=$(find "$root_api_path/$space/api/$api/requests" -maxdepth 1 -mindepth 1 -type d -printf "- %f\n")
        local opt=$(select_option "REQUESTS > " "/$space [$env]/APIS/$api/REQUESTS" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') existing_space_api_menu "$space" "$env" "$api" ;;
            'NEW') new_space_api_req_menu "$space" "$env" "$api" ;;
            'COPY EXISTING') new_space_api_req_from_existing_menu "$space" "$env" "$api" ;;
            *) [[ -n "$opt" ]] && existing_space_api_req_menu "$space" "$env" "$api" "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # SPACES/SN/APIS/AN
    function existing_space_api_menu() {
        local space=$1
        local env=$2
        local api=$3
        local options=('REQUESTS' 'INIT API' 'UPDATE (NVIM)'  '< BACK' )
        local opt=$(select_option "OPTIONS > " "/$space [$env]/APIS/$api" "${options[@]}")
        case "$opt" in
            '< BACK') space_apis_menu "$space" "$env" ;;
            'UPDATE (NVIM)') cd "$root_api_path/$space/api/$api" && nvim ;;
            'REQUESTS') space_api_reqs_menu $space $env $api ;;
            'INIT API') init_space_env_api "$space" "$env" "$api" ;;
        esac
    }
    # SPACES/SN/APIS
    function space_apis_menu() {
        local space=$1
        local env=$2
        local options=( 'NEW' '< BACK')
        local existing=$(find "$root_api_path/$space/api" -maxdepth 1 -mindepth 1 -type d  -printf "- %f\n")
        local opt=$(select_option "APIS > " "/$space [$env]/APIS" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') existing_space_env_menu "$space" "$env" ;;
            'NEW') new_space_api_menu "$space" "$env" ;;
            *) [[ -n "$opt" ]] && existing_space_api_menu "$space" "$env" "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # SPACES/SN/ENVS/EN/VARS/VN
    function existing_space_env_vars_menu() {
        local space=$1
        local env=$2
        local var=$3
        local options=( 'UPDATE (NVIM)' '< BACK')
        local opt=$(select_option "OPTIONS > " "/$space [$env]/VARS/$var" "${options[@]}")
        case "$opt" in
            '< BACK') space_env_vars_menu "$space" "$env" ;;
            'UPDATE (NVIM)') nvim "$root_api_path/$space/envs/$env/$var"  ;;
        esac
    }
    # SPACES/SN/ENVS/EN/VARS
    function space_env_vars_menu() {
        local space=$1
        local env=$2
        local options=( 'NEW' '< BACK')
        local existing=$(find "$root_api_path/$space/envs/$env" -maxdepth 1 -mindepth 1 -printf "- %f\n")
        local opt=$(select_option "VARS > " "/$space [$env]/VARS" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') existing_space_env_menu "$space" "$env" ;;
            'NEW') new_space_env_var_menu "$space" "$env" ;;
            *) [[ -n "$opt" ]] && existing_space_env_vars_menu "$space" "$env" "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # SPACES/SN/ENVS/EN
    function existing_space_env_menu() {
        local space=$1
        local env=$2
        export API_ENV=$env
        local options=('APIS' 'VARS' 'UPDATE (NVIM)' '< BACK' )
        local opt=$(select_option "OPTIONS > " "/$space [$env]" "${options[@]}")
        case "$opt" in
            '< BACK') space_envs_menu "$space" ;;
            'UPDATE (NVIM)') cd "$root_api_path/$space/envs/$env" && nvim ;;
            'APIS') space_apis_menu "$space" "$env" ;;
            'VARS') space_env_vars_menu "$space" "$env" ;;
        esac
    }
    # SPACES/SN/ENVS
    function space_envs_menu() {
        local space=$1
        local options=( 'NEW' '< BACK')
        local existing=$(find "$root_api_path/$space/envs" -maxdepth 1 -mindepth 1 -type d  -printf "- %f\n")
        local opt=$(select_option "ENVS > " "/$space [?]" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') existing_space_menu "$space" ;;
            'NEW') new_space_env_menu "$space" ;;
            *) [[ -n "$opt" ]] && existing_space_env_menu "$space" "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # SPACES/SN
    function existing_space_menu() {
        local space=$1
        export API_SPACE=$space
        local options=( 'ENVS' 'UPDATE (NVIM)'  '< BACK')
        local opt=$(select_option "OPTIONS > " "/$space" "${options[@]}")
        case "$opt" in
            '< BACK') spaces_menu ;;
            'UPDATE (NVIM)') cd "$root_api_path/$space" && nvim ;;
            'ENVS') space_envs_menu "$space" ;;
        esac
    }
    # SPACES
    function spaces_menu() {
        local options=( 'NEW' '< BACK')
        local existing=$(find "$root_api_path" -maxdepth 1 -mindepth 1 -type d  -printf "- %f\n")
        local opt=$(select_option "SPACES > " "/" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') api_root ;;
            'NEW') new_space_menu ;;
            *) [[ -n "$opt" ]] && existing_space_menu "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # TEMPLATES/TN
    function existing_template_menu() {
        local template=$1
        local options=('UPDATE (NVIM)' '< BACK' )
        local opt=$(select_option "OPTIONS > " "#$template" "${options[@]}")
        case "$opt" in
            '< BACK') spaces_menu ;;
            'UPDATE (NVIM)') cd "$root_templates_path/$template" && nvim ;;
        esac
    }
    # TEMAPLATES
    function templates_menu() {
        local options=('NEW' '< BACK' )
        local existing=$(find "$root_templates_path" -maxdepth 1 -mindepth 1 -type d  -printf "- %f\n")
        local opt=$(select_option "TEMPLATES > " "#" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') api_root ;;
            'NEW') new_template_menu ;;
            *) [[ -n "$opt" ]] && existing_template_menu "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # STASH/SN
    function existing_stash_menu() {
        local stashed=$1
        local options=('UPDATE (NVIM)' '< BACK' )
        local opt=$(select_option "OPTIONS > " "_$stashed" "${options[@]}")
        case "$opt" in
            '< BACK') spaces_menu ;;
            'UPDATE (NVIM)') cd "$root_stash_path" && nvim $stashed ;;
        esac
    }
    # STASH
    function stash_menu() {
        local options=('NEW' '< BACK' )
        local existing=$(find "$root_stash_path" -maxdepth 1 -mindepth 1  -printf "- %f\n")
        local opt=$(select_option "STASH > " "_" "${existing[@]}" "${options[@]}" )
        case "$opt" in
            '< BACK') api_root ;;
            'NEW') new_stash_menu ;;
            *) [[ -n "$opt" ]] && existing_stash_menu "$(echo "$opt" | sed 's/- //g')"  ;;
        esac
    }
    # ROOT
    function api_root() {
        local options=('SPACES' 'API TEMPLATES' 'STASH')
        local opt=$(select_option "SPACES > " "/" "${options[@]}")
        case "$opt" in
            'SPACES') spaces_menu ;;
            'API TEMPLATES') templates_menu ;;
            'STASH') stash_menu ;;
        esac
    }
    if [[ -n "$API_SPACE" && -n "$API_ENV" ]]; then
        existing_space_env_menu $API_SPACE $API_ENV
    elif [[ -n "$API_SPACE" && -z "$API_ENV" ]]; then
        existing_space_menu $API_SPACE
    else
        api_root
    fi

    unset -f api_root
}

#save to api stash
function save_api_stash () {
    local stash_name=$1
    shift
    local root_stash_path=$HOME/notes/apis/stash/
    printf $@ > $root_stash_path/$stash_name
}

function get_api_stash () {
    local stash_name=$1
    local root_stash_path=$HOME/notes/apis/stash/
    cat $root_stash_path/$stash_name
}
