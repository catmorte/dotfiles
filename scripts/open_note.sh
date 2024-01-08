#!/bin/zsh
open_note() {
    _zsh_highlight() {}
    notes=~/notes
    opt=$(ls $notes | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi

    note_name=$(ls $notes/"$opt" | fzf)
    if [[ "$?" -ne 0 ]]; then
        return
    fi
    folder=$notes/"$opt"/"$note_name"
    fullapth=$folder/note.md
    nvim $fullapth
}

if [ "${1}" != "--source-only" ]; then
    open_note "${@}"
fi

