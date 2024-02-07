run_notes() {
    types=('read' 'add')
    selected_type=$(printf "%s\n" "${types[@]}" | fzf)
    if [[ -z $selected_type ]]; then
        exit 0
    fi
    if [[ $selected_type == "read" ]]; then
        open_note $@
    else
        new_note $@
    fi
}
