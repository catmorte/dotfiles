sync_notes() {
	rclone sync --progress ~/notes/ ggld_e:notes
	if ! command -v ntfy &>/dev/null; then
		echo "synced"
	else
		ntfy send "Notes synced"
	fi
}

if [ "${1}" != "--source-only" ]; then
	sync_notes "${@}"
fi
