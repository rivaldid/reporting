#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX/"TEMP"

LOG=$PREFIX"/ser_parse.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

if [ -d $TEMP_DIR ]; then rm -rf $TEMP_DIR; fi
mkdir -p $TEMP_DIR

sudo mount $REPORT

for file in $(find $REPORT -name "*.xps" -type f); do

	INPUT=$file	# current file from loop
	filename="${INPUT##*/}" # simple filename.csv
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix
	
	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('serchio','$filereferer');")
	
	if [ "$report_done" = "0" ]; then
	
		echo "--> OK $INPUT da aggiungere" >> $LOG
		
		echo -n "Working $filereferer..."
		
		unzip $INPUT -d $TEMP_DIR &>/dev/null
		
		for subfile in $(find $TEMP_DIR -name "*.fpage" -type f); do
		
			#echo $subfile
			#UnicodeString=
			IFS=''
			while read -ra line; do
				
				echo ${line##UnicodeString}
				
			done < $subfile
		
		done
		
		#cleanup
		rm -rf $TEMP_DIR
		
		echo "ok!"
		 
	else 
		
		echo "--> NO $INPUT aggiunto" >> $LOG
			
	fi

done

sudo umount $REPORT
