run_secrets() {
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
