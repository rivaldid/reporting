#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX"/TEMP"

mask_data="^[0-9]{2}/[0-9]{2}/[0-9]{4}$"
mask_ora="^[0-9]{2}:[0-9]{2}$"
mask_centrale="^PULSAR[[:space:]][0-9]{1}$"
mask_concentratore="^([0-9]{3})$"

LOG=$PREFIX"/ser_parse.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

if [ -d $TEMP_DIR ]; then rm -rf $TEMP_DIR; fi
mkdir -p $TEMP_DIR

if grep -qs "$REPORT" /proc/mounts; then
    echo "--> $REPORT mounted."
else
    echo "--> $REPORT not mounted."
	sudo mount "$REPORT"
fi

for file in $(find $REPORT -name "*.xps" -type f); do

	INPUT=$file	# current file from loop
	filename="${INPUT##*/}" # simple filename.ext
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix

	checksum=$(md5sum ${INPUT} | awk '{ print $1 }')

	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('$checksum');")

	if [ "$report_done" = "0" ]; then

		echo "--> OK $INPUT da aggiungere" >> $LOG

		echo -n "Working $filereferer..."

		unzip $INPUT -d $TEMP_DIR &>/dev/null

		for subfile in $(find $TEMP_DIR -name "*.fpage" -type f); do

			while IFS=$'\n' read -ra line; do

				# target=(stampa riga |
				#		sostituisci " con spazio |
				#		sostituisci ' con spazio |
				#		cerca e togli UnicodeString= |
				#		togli /> |
				#		togli spazi multipli

				target=$(echo "$line" |
						sed "s/\"/ /g" |
						sed "s/'/ /g" |
						sed -n -e 's/^.*UnicodeString= //p' |
						sed 's/\/>//g' |
						tr -s ' ')

				# PARSER CORE
				if [[ -n "$target" ]] &&
					[[ ! "$target" =~ "TELEDATA ** Controllo Accessi **" ]] &&
					[[ ! "$target" =~ "- Stampa Report da" ]]; then

					echo "$target" >> $LOG
					
					trash=""
					
					#while IFS=' ' read -ra field; do
					for field in ${target[@]}; do

						if 	 [[ $field =~ $mask_data ]]; 		then printf -v data "$field"
						elif [[ $field =~ $mask_ora ]]; 		then printf -v ora "$field"
						elif [[ $field =~ $mask_centrale ]]; 	then printf -v centrale "$field"
						
						else trash+="$field "
						fi
						
						echo "A"$field"B"
						
					done
					
					echo $mycall
					
					mycall="CALL input_serchio('$data','$ora','$centrale','$seriale','$evento','$varco','$direzione','$ospite','$checksum');"
					#mycall="CALL input_serchio($(perl ser_parse_core.pl "$target"),'$checksum');"
					
					echo "$mycall" >> $LOG
					echo "--> unmatched: $trash" >> $LOG
					#mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1

				fi

			done < $subfile

		done

		#cleanup
		#mycall="CALL input_repo('serchio','$filereferer')"
		#mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1
		rm -rf $TEMP_DIR

		echo "ok!"

	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG

	fi

done

sudo umount $REPORT
