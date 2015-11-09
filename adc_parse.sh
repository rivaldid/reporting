#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/tempRAS"
TRASH_PREFIX="/mnt/tempRAS"

LOG=$PREFIX"/adc_parse.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

sudo mount $REPORT

for file in $(find $REPORT -name "*TO1*.xls" -type f); do
	
	INPUT=$file
	filename="${INPUT##*/}" # simple filename.ext
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix
	
	checksum=$(md5sum ${INPUT} | awk '{ print $1 }')
	
	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('$checksum');")

	if [ "$report_done" = "0" ]; then
	
		echo "--> OK $INPUT da aggiungere" >> $LOG
		echo "--> $TEMP in corso..." >> $LOG
		
		echo -n "Working $filereferer..."
		
		
		while read line; do
		
			echo $line
			
		done < $INPUT
		
		echo "ok!"
	
	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG
	fi
	
done

sudo umount $REPORT