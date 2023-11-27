# Create a new note with the current time as the title
new_note() {
	current_date=$(date "+%Y.%m.%d")
	current_time=$(date "+%H:%M:%S")
	echo "Enter note name: "
	read note_name
	mkdir -p ~/notes/
	touch ~/notes/"$current_date"_"$current_time"_"$note_name".md
	nvim ~/notes/"$current_date"_"$current_time"_"$note_name".md
	if [[ $? -eq 0 ]]; then
		echo "Syncing notes..."
		rclone sync --progress ~/notes/ ggld_e:notes
	else
		rm ~/notes/"$current_date"_"$current_time"_"$note_name".md
	fi
}
