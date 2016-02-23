#!/bin/bash

PREFIX="/home/vilardid/reporting"
source "$PREFIX/config.sh"

# mountpoint for different os
[[ $system =~ $redhat ]] && REPORT="/mnt2/tempRAS"
[[ $system =~ $centos ]] && REPORT="/mnt/tempRAS"

TRASH_PREFIX="/mnt/tempRAS/"
LOG="$PREFIX/adc_parse.log"

SKIPTEST=1

leading_whitespaces() { printf "$1" | sed -e 's/^[[:space:]]*//'; }
trailing_whitespaces() { printf "$1" | sed -e 's/[[:space:]]*$//'; }
combined_whitespaces() { leading_whitespaces "$(trailing_whitespaces "$1")"; }
trim_doublequotes() { printf "$1" | tr -d '"'; }
apos_substitution() { printf "${1//\'/&apos;}"; }

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

[[ -f $LOG ]] && rm $LOG
touch $LOG

[[ -f $ADC_HISTORY ]] || touch $ADC_HISTORY

case "$1" in
	--help)
		echo "Arguments: [--skip]"
		exit
		;;
	--skip)
		SKIPTEST=0
		;;
	*)
		echo "--> Nessun parametro in ingresso"
		;;
esac

if [[ "$SKIPTEST" == "1" ]]; then
	confirm || { echo "Bye"; exit; }
fi

#[[ ! -z "$1" ]] && { echo "WATCH OUT: not a WinWatch or Serchio script!"; exit; }
#confirm || { echo "Bye"; exit; }

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

	report_not_done=$(mysql $MYARGS -D reporting -s -N -e "SELECT test_repo('$checksum');")
	report_not_obsolete=$(mysql $MYARGS -D reporting -s -N -e "SELECT test_repo_adc((SELECT pre_adc_data('$data_report')),'$data_file');")

	if [ "$report_not_done" = "0" ] && [ "$report_not_obsolete" = "0" ]; then

		echo "-- > OK $INPUT da aggiungere" >> $LOG
		echo "--> $TEMP in corso..."

		echo "--> Cleanup:" $(mysql $MYARGS -D reporting -s -N -e "SELECT clean_adc_garbage((SELECT pre_adc_data('$data_report')),'$data_file');") "record"

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
						#valore="${field[$i]}"
						#valore="$(printf "$valore" | tr -d '\011\012\015' | sed -e 's/^ *//g;s/ *$//g' | tr -d '"')"
						#printf -v valore "%s" "$(echo "${field[$i]}" | tr -d '\011\012\015' | sed -e 's/^ *//g;s/ *$//g' | tr -d '"')"
						#printf -v valore "%s" "$(combined_whitespaces "$(trim_doublequotes "${field[$i]}")")"
						printf -v valore "%s" "$(combined_whitespaces "${field[$i]}")"
					fi

					case "$j" in
						0) printf -v cognome "$valore";;
						1) printf -v nome "$valore";;
						2) printf -v societa "$valore";;
						3) printf -v tipo_doc "$valore";;
						4) printf -v num_doc "$valore";;
						5) printf -v scad_doc "$valore";;
						6) printf -v decorrenza "$valore";;
						7) printf -v scadenza "$valore";;
						8) printf -v badge "$valore";;
						9) printf -v gruppo "$valore";;
						10) printf -v note "$valore";;
						11) printf -v struttura "$valore";;
						12) printf -v profilo "$valore";;
						13) printf -v cf "$valore";;
						14) printf -v data_di_nascita "$valore";;
						15) printf -v nazionalita "$valore";;
						#16 autorizzazione temporanea
						#17 telefono
						#18 badge pi
						#19 badge to
						#20 data center
						21) printf -v locali "$valore";;
					esac

					let "j++"

					#echo $valore

				#done <<< "$line"
				done <<< "$(trim_doublequotes "$(apos_substitution "$line")")"

			done < "$TEMP"

			mycall="CALL input_adc('$cognome','$nome','$societa','$tipo_doc','$num_doc','$scad_doc','$decorrenza','$scadenza','$badge','$gruppo','$note','$struttura','$profilo','$cf','$data_di_nascita','$nazionalita','$locali','$data_report','$checksum','$data_file');"
			mysql $MYARGS -D reporting -e "$mycall \W;" >> $LOG 2>&1

			echo "$mycall" >> $LOG

		done

		#cleanup
		rm $TEMP

		echo "ok!"

	#else

		#echo "-- > NO $INPUT aggiunto" >> $LOG
	fi

done

sudo umount $REPORT
cat "$LOG" >> "$ADC_HISTORY"