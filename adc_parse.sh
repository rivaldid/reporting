#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/tempRAS"
TRASH_PREFIX="/mnt/tempRAS/"

LOG=$PREFIX"/adc_parse.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

if grep -qs "$REPORT" /proc/mounts; then
    echo "--> $REPORT mounted."
else
    echo "--> $REPORT not mounted."
	sudo mount "$REPORT"
fi


for file in $(find $REPORT -name "*TO1*.xls" -type f); do
	
	INPUT=$file
	filename="${INPUT##*/}" # simple filename.ext
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix
	TEMP="$PREFIX/$filename.temp.csv"
	
	checksum=$(md5sum ${INPUT} | awk '{ print $1 }')
	
	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('$checksum');")

	if [ "$report_done" = "0" ]; then
	
		echo "==> OK $INPUT da aggiungere"
		echo "--> $TEMP in corso..."
		
		echo "--> Working $filereferer..."
		
		# converto e codifico
		convertxls2csv_altsep -x "$INPUT" -b WINDOWS-1252 -c "$TEMP" -a UTF-8
		
		#fields=()
		i=0
		while read line; do
		
			j=0
			while IFS='~' read -ra field; do
				#echo "valore: $field"
				output[$j]="${field[@]:$i:1}"
			done <<< "$line"
		
			#fields[$i]=$(grep -o "~" <<< "$line" | wc -l)
			i=$i+1
			
			echo ${output[@]}
			
		done < $TEMP

		#echo "numero campi per colonne: ${fields[@]}"
		#echo "numero righe: ${#fields[@]}"
		
		#cleanup
		rm $TEMP
		
		echo "--> $filereferer done!"
	
	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG
	fi
	
done

sudo umount $REPORT