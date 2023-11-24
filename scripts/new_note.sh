# Create a new note with the current time as the title and sync
new_note() {
	current_date=$(date "+%Y.%m.%d")
	current_time=$(date "+%H:%M:%S")
	read note_name
	mkdir -p ~/notes/
	touch ~/notes/"$current_date"_"$current_time"_"$note_name".md
	nvim ~/notes/"$current_date"_"$current_time"_"$note_name".md
	rclone sync --progress ~/notes/ ggld_e:notes
}
