#!/bin/zsh
read_secret() {
    _zsh_highlight() {}

    notes=~/notes/keys/
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(ls $notes/"$opt" | fzf)
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

if [ "${1}" != "--source-only" ]; then
    read_secret "${@}"
fi
