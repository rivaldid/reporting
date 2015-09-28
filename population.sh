#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/population.log"
MYARGS="-H -ureporting -preportuser -D reporting"


if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

INPUT="test.csv"

MAIN_FS=$IFS
while read line; do
	while IFS=';' read -ra field; do
		#centrale=${${field[0]}//[[:blank:]]/}
		centrale="${field[0]//[[:blank:]]/}"
		ora="${field[1]//[[:blank:]]/}"
		data="${field[2]//[[:blank:]]/}"
		azione="${field[3]//[[:blank:]]/}"
		messaggio="${field[4]//[[:blank:]]/}"
	done<<<$line
	mycall="CALL input_winwatch('$centrale','$ora','$data','$azione','$messaggio')"
	echo $mycall
	#mysql $MYARGS -e "$mycall \W;" >> $LOG
	IFS=$MAIN_IFS
done<$INPUT
