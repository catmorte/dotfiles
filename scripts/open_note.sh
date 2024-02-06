#!/bin/zsh
open_note() {
    _zsh_highlight() {}
    notes=~/notes/plain/docs
    opt=$(find $notes -maxdepth 1 -mindepth 1 -type d  -printf "%f\n" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(ls $notes/"$opt" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi
    folder=$notes/"$opt"/"$note_name"
    fullapth=$folder/note.md
    tmux neww bash -c "nvim $fullapth"
}

if [ "${1}" != "--source-only" ]; then
    open_note "${@}"
fi
