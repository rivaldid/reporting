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


for file in $(find $REPORT -name "ReportGiornaliero_TO1*.xls" -type f); do
	
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
		
		#awk -F'~' 'BEGIN {i=0} {for (i=1;i<=NF;i++) print $i}' "$TEMP" |tr -d '"'
		
		for ((i=0; i<=$(wc -l "$TEMP" | cut -f1 -d' '); i++)); do
		
			#echo "--> riga $i-esima"
			output=()
			j=0
		
			while read line; do
			
				while IFS='~' read -ra field; do
					
					if [ -z "${field[$i]}" ]; then 
						valore=NULL
					else
						valore="${field[$i]}"
						valore="$(printf "$valore" | tr -d '\011\012\015' | sed -e 's/^ *//g;s/ *$//g' | tr -d '"')"
					fi
				
					case "$j" in
						0) cognome="$valore";;
						1) nome="$valore";;
						2) societa="$valore";;
						3) tipo_doc="$valore";;
						4) num_doc="$valore";;
						5) scad_doc="$valore";;
						6) decorrenza="$valore";;
						7) scadenza="$valore";;
						8) badge="$valore";;
						9) gruppo="$valore";;
						10) note="$valore";;
						11) struttura="$valore";;
						12) profilo="$valore";;
						13) cf="$valore";;
						14) data_di_nascita="$valore";;
						15) nazionalita="$valore";;
						#15 autorizzazione temporanea
						#16 telefono
						#17 badge pi
						#18 badge to
						#19 data center
						21) locali="$valore";;
					esac
					
					let "j++"
					
					#echo $valore
					
				done <<< "$line"
				
				#echo "${output[@]}"
				
			done < "$TEMP"
			
			echo "CALL input_adc('$cognome','$nome','$societa','$tipo_doc','$num_doc','$scad_doc','$decorrenza','$scadenza','$badge','$gruppo','$note','$struttura','$profilo','$cf','$data_di_nascita','$nazionalita','$locali','$checksum');"

		done
		
		#cleanup
		rm $TEMP
		
		echo "--> $filereferer done!"
	
	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG
	fi
	
done

sudo umount $REPORT