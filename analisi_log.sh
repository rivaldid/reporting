#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$1
ANALYZED=$1".analyzed.log"
touch $ANALYZED

declare -a targets=("CALL input_winwatch" "ERROR 1062")

if [ -f $LOG ]; then

	while read line; do
	
		found=1 #inizializzo falso found
	
		for i in "${targets[@]}"; do
		
			# se trovo matching found vero
			if [[ $line =~ $i* ]]; then
				found=0
			fi
		
		done
		
		if [[ $found = false ]]; then
			echo $line >> $ANALYZED
		fi
	
	done < $LOG

fi
