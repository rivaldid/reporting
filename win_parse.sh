#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/WinWatch"

LOG=$PREFIX"/win_parse.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

sudo mount $REPORT

for file in $(find $REPORT -name "*.csv" -type f); do

	INPUT=$file	# current file from loop
	filename="${INPUT##*/}" # simple filename.csv
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix
	TEMP=$PREFIX/$filename.temp.csv # conversion latin to utf (windows to linux)

	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('winwatch','$filereferer');")

	if [ "$report_done" = "0" ]; then

		echo "--> OK $INPUT da aggiungere" >> $LOG
		echo "--> $TEMP in corso..." >> $LOG

		echo -n "Working $filereferer..."

		iconv -f "windows-1252" -t "UTF-8" $INPUT -o $TEMP

		while read line; do

			while IFS=';' read -ra field; do

				centrale="${field[0]}"
				ora="${field[1]}"
				data="${field[2]}"
				evento="${field[3]}"
				messaggio="${field[4]}"

				if [ -z "${field[0]}" ];then centrale=NULL; fi
				if [ -z "${field[1]}" ];then ora=NULL; fi
				if [ -z "${field[2]}" ];then data=NULL; fi
				if [ -z "${field[3]}" ];then evento=NULL; fi
				if [ -z "${field[4]}" ];then messaggio=NULL; fi

				centrale="$(echo "$centrale" | tr -d '\n' | sed "s/'/ /g" | sed -e 's/^ *//g;s/ *$//g' |tr -s ' ')"
				ora="$(echo "$ora" | tr -d '\n' | sed "s/'/ /g" | sed -e 's/^ *//g;s/ *$//g' | tr -s ' ')"
				data="$(echo "$data" | tr -d '\n' | sed "s/'/ /g" | sed -e 's/^ *//g;s/ *$//g' | tr -s ' ')"
				evento="$(echo "$evento" | tr -d '\n' | sed "s/'/ /g" | sed -e 's/^ *//g;s/ *$//g' | tr -s ' ')"
				messaggio="$(echo "$messaggio" | tr -d '\n' | sed "s/'/ /g" |sed -e 's/^ *//g;s/ *$//g' | tr -s ' ')"

				# fix random wrong position
				if [ "${centrale:2:1}" == ":" ] && [ "${ora:2:1}" == "-" ]; then
					printf -v tmp "$data $evento"
					printf -v evento "$tmp"
					printf -v data "$ora"
					printf -v ora "$centrale"
					printf -v centrale NULL
				fi

			done <<< $line

			mycall="CALL input_winwatch('$centrale','$ora','$data','$evento','$messaggio','$filereferer');"
			echo $mycall >> $LOG
			mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1

		done < $TEMP

		# cleanup
		#mycall="CALL input_repo('winwatch','$filereferer');"
		#mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1
		rm $TEMP

		echo "ok!"

	else

		echo "--> NO $INPUT aggiunto" >> $LOG

	fi

done

sudo umount $REPORT

cat $LOG | mail -s "script win_parse reporting db" vilardid@localhost