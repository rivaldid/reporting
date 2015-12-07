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

reventi_qutenzaq='(.*)([[:graph:]][[:space:]].*[[:space:]][[:graph:]])(.*)'
reventi_nable='(.*)([[:alpha:]]{1,3}]BILITATO)(.*)'
reventi_durata='(.*)([[:graph:]]durata.*[[:graph:]])(.*)'

reventi='(.*)(' # 1-2
reventi+='(Scasso[[:space:]]varco)|' #3
reventi+='(Varco[[:space:]]chiuso)|' #4
reventi+='(Varco[[:space:]]non[[:space:]]chiuso)|' #5
reventi+='(Varco[[:space:]]non[[:space:]]aperto)|' #6
reventi+='(Transito[[:space:]]effettuato)|' #7
reventi+='(Transito[[:space:]]non[[:space:]]consentito)|' #8
reventi+='(Tessera[[:space:]]inesistente)|' #9
reventi+='(Caduta[[:space:]]Linea[[:punct:]])|' #10
reventi+='(Linea[[:space:]]Mini[[:space:]]Pulsar[[:punct:]])|' #11

reventi+='(ADMIN[0-9][[:space:]]Tastiera[[:space:]]Abilitata[[:punct:]][[:space:]])|' #12
reventi+='(VISUAL[[:space:]]Tastiera[[:space:]]Abilitata[[:punct:]][[:space:]])|' #13

reventi+='(Allarmi[[:space:]]Acquisiti[[:graph:]].*[[:graph:]]{2}[[:space:]])|' #14
reventi+='(Allarme[[:space:]]Tamper)|' #15

reventi+='(Richiesta[[:space:]]Invio[[:space:]]Programmazione[[:space:]][[:punct:]][[:space:]])|' #16
reventi+='(Fine[[:space:]]invio[[:space:]]dati[[:space:]]di[[:space:]]programmazione[[:punct:]])|' #17
reventi+='(Comando[[:space:]]Cambio[[:space:]]Stato[[:space:]]Lettore)|' #18
reventi+='(Richiesta[[:space:]]Comando[[:space:]]Apertura[[:space:]]Varco)|' #19
reventi+='(Apertura[[:space:]]varco[[:space:]]Console[[:punct:]])|' #20
reventi+='(Allarme[[:space:]]ingresso[[:space:]][0-9])|' #21
reventi+='(Stato[[:space:]]Lettore)|' #22
reventi+='(Fine[[:space:]]transito)|' #23
reventi+='(Ripristino[[:space:]]Linea)' #24
reventi+=')(.*)' #25
reventi_max=25

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
					unset data centrale seriale evento varco direzione ospite eventi_nable eventi_durata eventi_utenza
					printf -v buffer "$target"
					
					# trash
					[[ $buffer =~ $rconcentratore ]] && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					
					# componenti
					[[ $buffer =~ $reventi_nable ]] && eventi_nable=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_durata ]] && eventi_durata=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_qutenzaq ]] && eventi_utenza=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					
					# contents
					[[ $buffer =~ $rdata ]] && data=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rcentrale ]] && centrale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rseriale ]] && seriale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rvarco ]] && varco=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi ]] && evento=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$reventi_max]}
					
					# concateno i componenti
					[[ -n $eventi_nable ]] && printf -v evento "%s %s" "$evento" "$eventi_nable"
					[[ -n $eventi_durata ]] && printf -v evento "%s %s" "$evento" "$eventi_durata"
					[[ -n $eventi_utenza ]] && printf -v ospite "%s %s" "$ospite" $(echo "$eventi_utenza" | tr -d '[|]')
									
					mycall="CALL input_serchio('$data','$centrale','$seriale','$evento','$varco','$direzione','$ospite','$checksum');"
					#printf -v mycall "CALL input_serchio('%s','%s','%s','%s','%s','%s','%s','%s');" $(unspace "$data") $(unspace "$centrale") $(unspace "$seriale") $(unspace "$evento") $(unspace "$varco") $(unspace "$direzione") $(unspace "$ospite") "$checksum"
					#mycall="CALL input_serchio($(perl ser_parse_core.pl "$target"),'$checksum');"
					
					echo "$mycall" >> $LOG
									
					if [ ! -z "$(unspace "$buffer")" ]; then
						echo "==> $filereferer" >> $TODO
						echo "$target" >> $TODO
						echo "$buffer" >> $TODO
						echo "--> unmatched: $buffer" >> $LOG
						
						echo "$target"
						echo "$mycall"
						echo "$buffer"
						
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
