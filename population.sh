#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"

LOG=$PREFIX"/population.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

sudo mount $REPORT

#INPUT="test.csv"

for file in $(find $REPORT -name "*.csv" -type f); do

	INPUT=$file	
	#TEMP=$PREFIX/"${INPUT##*/}".temp.csv
	TEMP=$PREFIX/temp.csv
	
	echo $INPUT >> $LOG
	echo $TEMP >> $LOG

	iconv -f "windows-1252" -t "UTF-8" $INPUT -o $TEMP

	while read line; do
		while IFS=';' read -ra field; do
			
			centrale="${field[0]}"
			ora="${field[1]}"
			data="${field[2]}"
			azione="${field[3]}"
			messaggio="${field[4]}"
			
			# extra whitespaces
			centrale=($centrale)
			ora=($ora)
			data=($data)
			azione=($azione)
			messaggio=($messaggio)
			
			# cr
			centrale=$(echo $centrale|tr -d '\n')
			ora=$(echo $ora|tr -d '\n')
			data=$(echo $data|tr -d '\n')
			azione=$(echo $azione|tr -d '\n')
			messaggio=$(echo $messaggio|tr -d '\n')
			
		done <<< $line
		
		mycall="CALL input_winwatch('${centrale[@]}','${ora[@]}','${data[@]}','${azione[@]}','${messaggio[@]}')"
		echo $mycall >> $LOG
		mysql $MYARGS -e "$mycall \W;" >> $LOG
	done < $TEMP

	rm $TEMP

done

sudo umount $REPORT