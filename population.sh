#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/population.log"
MYARGS="-H -ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

INPUT="test.csv"

iconv -f "windows-1252" -t "UTF-8" $INPUT -o temp.$INPUT

while read line; do
	while IFS=';' read -ra field; do
		centrale="${field[0]}"
		ora="${field[1]}"
		data="${field[2]}"
		azione="${field[3]}"
		messaggio="${field[4]}"
	done <<< $line
	
	mycall="CALL input_winwatch('$centrale','$ora','$data','$azione','$messaggio')"
	#echo $mycall
	mysql $MYARGS -e "$mycall \W;" >> $LOG
done < temp.$INPUT

rm temp.$INPUT
