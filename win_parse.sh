#!/bin/bash

source "config.sh"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/WinWatch"

LOG="$PREFIX/win_parse.log"
WIN_HISTORY="$PREFIX/win_parse.history.log"

SKIPTEST=1

leading_whitespaces() { printf "%s\n" "$1" | sed -e 's/^[[:space:]]*//'; }
trailing_whitespaces() { printf "%s\n" "$1" | sed -e 's/[[:space:]]*$//'; }
apos_substitution() { printf "%s\n" "${1//\'/&apos;}"; }
trim_doublespaces() { printf "%s\n" "$1" | tr -s ' '; }

combined_whitespaces() { leading_whitespaces "$(trailing_whitespaces "$1")"; }
string_cleanup() { combined_whitespaces "$(trim_doublespaces "$(apos_substitution "$1")")"; }

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}


[[ -f $LOG ]] && rm $LOG
touch $LOG

[[ -f $WIN_HISTORY ]] || touch $WIN_HISTORY

case "$1" in
	--help) 
		echo "Arguments: [--partial /mnt/REPORT/WinWatch/foo/bar/baz.xps] OR [--skip]"
		exit
		;;
	--partial)
		PARTIAL="${2##$REPORT}"
		if [[ -z "$PARTIAL" ]]; then
			echo "Doing nothing, bye"
			exit 1 
		fi
		;;
	--skip)
		SKIPTEST=0
		;;
	*) 
		echo "--> Nessun parametro in ingresso"
		;;
esac

if [[ "$SKIPTEST" == "1" ]]; then
	confirm || { echo "Bye"; exit; }
fi
		

# arguments: --partial /foo/bar/baz.xps
#if [[ ! -z "$1" ]]; then
#	[[ "$1" == "--help" ]] && { echo "Arguments: [--partial /mnt/REPORT/WinWatch/foo/bar/baz.xps] OR [--skip]"; exit; }
#	[[ "$1" == "--partial" ]] && PARTIAL="${2##$REPORT}" || { echo "What?"; exit; }
#	[[ "$1" == "--skip"]] && SKIP=0

#	if [[ ! -z "$PARTIAL" ]]; then
#		confirm || { echo "Bye"; exit; }
#	else
#		echo "Doing nothing, bye"; exit 1
#	fi
#else
#	confirm || { echo "Bye"; exit; }
#fi

if grep -qs "$REPORT" /proc/mounts; then
    echo "--> $REPORT mounted."
else
    echo "--> $REPORT not mounted."
	sudo mount "$REPORT"
fi

for file in $(find $REPORT$PARTIAL -name "*.csv" -type f); do

	INPUT="$file"	# current file from loop
	filename="${INPUT##*/}" # simple filename.ext
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix
	TEMP="$PREFIX/$filename.temp.csv" # conversion latin to utf (windows to linux)

	checksum=$(md5sum ${INPUT} | awk '{ print $1 }')

	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('$checksum');")

	if [ "$report_done" = "0" ]; then

		echo "--> OK $INPUT da aggiungere" >> $LOG
		#echo "--> $TEMP in corso..." >> $LOG

		echo -n "Working $filereferer..."

		iconv -f "windows-1252" -t "UTF-8" $INPUT -o $TEMP

		while read line; do

			while IFS=';' read -ra field; do

				# input
				[[ -z "${field[0]}" ]] && printf -v centrale NULL || printf -v centrale "%s" "$(string_cleanup "${field[0]}")"
				[[ -z "${field[1]}" ]] && printf -v ora NULL || printf -v ora "%s" "$(string_cleanup "${field[1]}")"
				[[ -z "${field[2]}" ]] && printf -v data NULL || printf -v data "%s" "$(string_cleanup "${field[2]}")"
				[[ -z "${field[3]}" ]] && printf -v evento NULL || printf -v evento "%s" "$(string_cleanup "${field[3]}")"
				[[ -z "${field[4]}" ]] && printf -v messaggio NULL || printf -v messaggio "%s" "$(string_cleanup "${field[4]}")"

				# fix random wrong position
				if [ "${centrale:2:1}" == ":" ] && [ "${ora:2:1}" == "-" ]; then
					printf -v tmp "$data $evento"
					printf -v evento "$tmp"
					printf -v data "$ora"
					printf -v ora "$centrale"
					printf -v centrale NULL
				fi

			done <<< $line

			mycall="CALL input_winwatch('$centrale','$ora','$data','$evento','$messaggio','$checksum');"
			echo $mycall >> $LOG
			mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1

		done < $TEMP

		# cleanup
		rm $TEMP

		echo "ok!"

	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG

	fi

done

sudo umount $REPORT
cat "$LOG" >> "$WIN_HISTORY"