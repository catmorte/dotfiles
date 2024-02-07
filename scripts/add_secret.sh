#!/bin/zsh
add_secret() {
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

    notes=~/notes/keys/
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
        nohup ./sync_notes.sh >/dev/null 2>&1 &
        disown
    else
        rm $fullapth
    fi
}

if [ "${1}" != "--source-only" ]; then
    add_secret "${@}"
fi
