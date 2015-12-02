#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX"/TEMP"

LOG=$PREFIX"/ser_parse.log"
TODO=$PREFIX"/ser_parse_unmatched.log"

MYARGS="-H -ureporting -preportuser -D reporting"

nospace() { printf "$1" | sed -e 's/^[[:space:]]*//'; }


# regex
mask_data="^[0-9]{2}/[0-9]{2}/[0-9]{4}[[:space:]][0-9]{2}:[0-9]{2}$"
mask_centrale="^[[:space:]]PULSAR[[:space:]][0-9]{1}$"
mask_concentratore="^[[:space:]]\([0-9]{3}\)$"
mask_varco="^[[:space:]]H\([0-9]{2}\)$"
mask_seriale="^[[:space:]][0-9]{8}$"

mask_evento="^
[[[:space:]]Scasso[[:space:]]varco]?
[[[:space:]]Varco[[:space:]]chiuso]?
[[[:space:]]Varco[[:space:]]non[[:space:]]chiuso]?
[[[:space:]]Transito[[:space:]]effettuato]?
[[[:space:]]Tessera[[:space:]]inesistente]?
[[[:space:]]Caduta[[:space:]]linea.]?$"

# /regex


if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

if [ -f $TODO ]; then rm $TODO; fi
touch $TODO

if [ -d $TEMP_DIR ]; then rm -rf $TEMP_DIR; fi
mkdir -p $TEMP_DIR

if grep -qs "$REPORT" /proc/mounts; then
    echo "--> $REPORT mounted."
else
    echo "--> $REPORT not mounted."
	sudo mount "$REPORT"
fi

for file in $(find $REPORT -name "*.xps" -type f); do

	INPUT="$file"	# current file from loop
	filename="${INPUT##*/}" # simple filename.ext
	filereferer="${INPUT#$TRASH_PREFIX}" # full path without trash prefix

	checksum=$(md5sum ${INPUT} | awk '{ print $1 }')

	report_done=$(mysql -ureporting -preportuser -D reporting -s -N -e "SELECT test_repo('$checksum');")

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
				if [[ -n "$target" ]] &&
					[[ ! "$target" =~ "TELEDATA ** Controllo Accessi **" ]] &&
					[[ ! "$target" =~ "- Stampa Report da" ]]; then

					#echo "$target"
					
					trash=""
					buffer=""
					i=0
					
					# PSEUDO
					# while read char; do
					# buffer <-- char; i++
					# if buffer is mask_myvar; then myvar = buffer; i=i - buffer_lenght; buffer = buffer - iesimi chars
					# elif buffer is other_mask_myvar; then SAME_STATEMENT_WITH_OTHER_MYVAR
					# fi; done
					
					#while IFS=' ' read -ra field; do
					#for field in ${target[@]}; do
					while IFS= read -r -N 1 char; do
						
						buffer+="$char"; let "i++"

						if   [[ $buffer =~ $mask_data ]]; then printf -v data "$(nospace "$buffer")"; i=$(( $i - ${#buffer} )); buffer="${buffer::-$i}"
						elif [[ $buffer =~ $mask_centrale ]]; then printf -v centrale "$(nospace "$buffer")"; i=$(( $i - ${#buffer} )); buffer="${buffer::-$i}"
						elif [[ $buffer =~ $mask_seriale ]]; then printf -v seriale "$(nospace "$buffer")"; i=$(( $i - ${#buffer} )); buffer="${buffer::-$i}"
						elif [[ $buffer =~ $mask_evento ]]; then printf -v evento "$(nospace "$buffer")"; i=$(( $i - ${#buffer} )); buffer="${buffer::-$i}"
						elif [[ $buffer =~ $mask_varco ]]; then printf -v varco "$(nospace "$buffer")"; i=$(( $i - ${#buffer} )); buffer="${buffer::-$i}"
						
						elif [[ $buffer =~ $mask_concentratore ]]; then i=$(( $i - ${#buffer} )); buffer="${buffer::-$i}"
						
						fi
						
					done <<< "$target"
					
					mycall="CALL input_serchio('$data','$centrale','$seriale','$evento','$varco','$direzione','$ospite','$checksum');"
					#mycall="CALL input_serchio($(perl ser_parse_core.pl "$target"),'$checksum');"
					
					echo "$mycall" >> $LOG
					
					if [ ! -z "$(nospace "$buffer")" ]; then
						echo "==> $filereferer" >> $TODO
						echo "$target" >> $TODO
						echo "$buffer" >> $TODO
						echo "--> unmatched: $buffer" >> $LOG
					fi
					
					#mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1

				fi

			done < $subfile

		done

		#cleanup
		rm -rf $TEMP_DIR

		echo "ok!"

	#else

		#echo "--> NO $INPUT aggiunto" >> $LOG

	fi

done

sudo umount $REPORT
