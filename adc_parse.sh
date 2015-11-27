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
	
	INPUT="$file"
	filename="${INPUT##*/}" # simple filename.ext
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix
	TEMP="$PREFIX/$filename.temp.csv"
	TRANS_TEMP="$PREFIX/$filename.trans.temp.csv"
	
	#date_container="${filename#ReportGiornaliero_TO1__}"
	#date_container="${date_container%.xls}"
	#date_container="$(echo $date_container | tr '_' '/')"
	
	data_report="$(printf "%s" "${filename:23:10}" | tr '_' '/')"
	data_file="$(date -r $INPUT +'%Y-%m-%d %H.%M.%S')"
	#data_file=$(printf "%d/%d/%d %d" "${date_container:11:2}" "${date_container:13:2}" "${date_container:15:4}" "${date_container:19}")
	
	checksum=$(md5sum ${INPUT} | awk '{ print $1 }')
	
	report_not_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('$checksum');")
	report_not_obsolete=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo_adc((SELECT pre_adc_data('$data_report')),'$data_file');")

	if [ "$report_not_done" = "0" ] && [ "$report_not_obsolete" = "0" ]; then
	
		echo "==> OK $INPUT da aggiungere" >> $LOG
		echo "--> $TEMP in corso..."
		
		echo "--> Cleanup:" $(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT clean_adc_garbage((SELECT pre_adc_data('$data_report')),'$data_file');") "record"
		
		echo -n "--> Working $filereferer..."
		
		# converto e codifico
		convertxls2csv_altsep -x "$INPUT" -b WINDOWS-1252 -c "$TEMP" -a UTF-8 &>/dev/null
		
		# conta colonne da usare come righe (per la trasposizione)
		prima_riga="$(head -n 1 "$TEMP" | sed s/\"//g | tr -d '[[:space:]]')"
		colonne="$(grep -o "[[:alpha:]]~" <<< "$prima_riga" | wc -l)"
			
		# conta righe
		#righe="$(wc -l "$TEMP" | cut -f1 -d' ')"
		
		#for ((i=1; i<=$(wc -l "$TEMP" | cut -f1 -d' '); i++)); do
		for ((i=1; i<=$colonne; i++)); do
		
			#echo "--> riga $i-esima"
			j=0
		
			while read line; do
				
				#line_lenght="$(echo $line | cut -d'~' -f 1 | wc -c)"
				
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
				
			done < "$TEMP"
			
			mycall="CALL input_adc('$cognome','$nome','$societa','$tipo_doc','$num_doc','$scad_doc','$decorrenza','$scadenza','$badge','$gruppo','$note','$struttura','$profilo','$cf','$data_di_nascita','$nazionalita','$locali','$data_report','$checksum','$data_file');"
			echo "$mycall" >> $LOG
			mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1

		done
		
		#cleanup
		rm $TEMP
		
		echo "ok!"
	
	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG
	fi
	
done

sudo umount $REPORT