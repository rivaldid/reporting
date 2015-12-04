#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX"/TEMP"

LOG=$PREFIX"/ser_parse.log"
TODO=$PREFIX"/ser_parse_unmatched.log"

MYARGS="-H -ureporting -preportuser -D reporting"

unspace() { printf "$1" | sed -e 's/^[[:space:]]*//'; }


# regex
rdata='(.*)([0-9]{2}/[0-9]{2}/[0-9]{4}[[:space:]][0-9]{2}:[0-9]{2})(.*)'
rcentrale='(.*)(PULSAR[[:space:]][0-9])(.*)'
rconcentratore='(.*)(\([0-9]{3}\))(.*)'
rseriale='(.*)([0-9]{8})(.*)'
rvarco='(.*)(H\([0-9]{2}\))(.*)'

reventi='(.*)('
reventi+='(Scasso[[:space:]]varco)?'
reventi+='(Varco[[:space:]]chiuso)?'
reventi+='(Varco[[:space:]]non[[:space:]]chiuso)?'
reventi+='(Transito[[:space:]]effettuato)?'
reventi+='(Tessera[[:space:]]inesistente)?'
reventi+=')(.*)'

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

					echo "$target"
					printf -v buffer "$target"
					
					[[ $buffer =~ $rdata ]] && data=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rcentrale ]] && centrale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rconcentratore ]] && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rseriale ]] && seriale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rvarco ]] && varco=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					
					[[ $buffer =~ $reventi ]] && evento=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
										
					mycall="CALL input_serchio('$data','$centrale','$seriale','$evento','$varco','$direzione','$ospite','$checksum');"
					#mycall="CALL input_serchio($(perl ser_parse_core.pl "$target"),'$checksum');"
					
					echo "$mycall" >> $LOG
					
					echo "$mycall"
					echo "$buffer"
					
					if [ ! -z "$(unspace "$buffer")" ]; then
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
