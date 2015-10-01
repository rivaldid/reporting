#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"

LOG=$PREFIX"/population.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

sudo mount $REPORT

for file in $(find $REPORT -name "*.csv" -type f); do

	INPUT=$file	
	filename="${INPUT##*/}"
	filereferer="${INPUT#/mnt/REPORT/WinWatch}"
	TEMP=$PREFIX/$filename.temp.csv
	
	#echo $INPUT >> $LOG
	#echo $TEMP >> $LOG
	
	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('winwatch','$filereferer');")
	#echo $report_done >> $LOG
	
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
				azione="${field[3]}"
				messaggio="${field[4]}"
				
				if [ -z "${field[0]}" ];then centrale=NULL; fi
				if [ -z "${field[1]}" ];then ora=NULL; fi
				if [ -z "${field[2]}" ];then data=NULL; fi
				if [ -z "${field[3]}" ];then azione=NULL; fi
				if [ -z "${field[4]}" ];then messaggio=NULL; fi
				
				printf -v centrale $(echo ${centrale[@]} | tr -d '\n')
				printf -v ora $(echo ${ora[@]} | tr -d '\n')
				printf -v data $(echo ${data[@]} | tr -d '\n')
				printf -v azione $(echo ${azione[@]} | tr -d '\n')
				printf -v messaggio $(echo ${messaggio[@]} | tr -d '\n')
						
			done <<< $line
			
			mycall="CALL input_winwatch('$centrale','$ora','$data','$azione','$messaggio')"
			echo $mycall >> $LOG
			mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1
			
		done < $TEMP
		
		# cleanup
		mycall="CALL input_repo('winwatch','$filereferer')"
		mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1
		rm $TEMP
		
		echo "ok!"
	
	else 
		
		echo "--> NO $INPUT aggiunto" >> $LOG
			
	fi

done

sudo umount $REPORT