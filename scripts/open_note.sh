#!/bin/zsh
open_note() {
	_zsh_highlight() {}
	notes=~/notes
	typeset -a options
	options=("$notes"/*)
	iter=1
	for opt in "${options[@]}"; do
		options[$iter]=$(basename "$opt")
		((iter++))
	done
	select opt in "${options[@]}"; do
		if [ "$opt" != "" ]; then
			break
		fi
	done

  note_name=$(ls $notes/"$opt" | fzf)

	folder=$notes/"$opt"/"$note_name"
	mkdir -p $folder
	fullapth=$folder/note.md
	nvim $fullapth
}

if [ "${1}" != "--source-only" ]; then
	open_note "${@}"
fi
