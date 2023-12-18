#!/bin/zsh
new_note() {
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

	current_date=$(date "+%Y.%m.%d")
	current_time=$(date "+%H:%M:%S")

	echo "Enter note name: "
	read note_name

	folder=$notes/"$opt"/"$current_date"_"$current_time"_"$note_name"
	mkdir -p $folder
	fullapth=$folder/note.md
	touch $fullapth
	nvim $fullapth
	if [[ $? -eq 0 ]]; then
		nohup ./sync_notes.sh >/dev/null 2>&1 &
		disown
	else
		rm $fullapth
	fi
}

if [ "${1}" != "--source-only" ]; then
	new_note "${@}"
fi
