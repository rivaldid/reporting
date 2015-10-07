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
				if [[ -n "$target" ]]; then
					
					echo "$target" >> $LOG
				
					while IFS=' ' read -ra field; do
					
						#data="${field[0]}"
						#ora="${field[1]}"
					
					done <<< "$target"
				
				fi
				
				
			done < $subfile
		
		done
		
		#cleanup
		mycall="CALL input_repo('serchio','$filereferer')"
		mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1
		rm -rf $TEMP_DIR
		
		echo "ok!"
		 
	else 
		
		echo "--> NO $INPUT aggiunto" >> $LOG
			
	fi

done

sudo umount $REPORT
