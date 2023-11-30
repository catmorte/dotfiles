#!/bin/bash
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

	folder=$notes/"$opt"/"$current_date"
	mkdir -p $folder
	fullapth=$folder/"$current_time"_"$note_name".md
	touch $fullapth
	nvim $fullapth
	if [[ $? -eq 0 ]]; then
		echo "Syncing notes..."
		rclone sync --progress ~/notes/ ggld_e:notes
	else
		rm $fullapth
	fi
}
