#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX"/TEMP"

LOG=$PREFIX"/ser_parse.log"
TODO=$PREFIX"/ser_parse_unmatched.log"

MYARGS="-H -ureporting -preportuser -D reporting"

leading_whitespaces() { printf "$1" | sed -e 's/^[[:space:]]*//'; }
trailing_whitespaces() { printf "$1" | sed -e 's/[[:space:]]*$//'; }
remove_punctuation() { printf "$1" | tr -d '[:punct:]'; }

combined_whitespaces() { leading_whitespaces "$(trailing_whitespaces "$1")"; }
string_cleanup() { combined_whitespaces "$(remove_punctuation "$buffer")"; }

# regex
rdata='(.*)([0-9]{2}/[0-9]{2}/[0-9]{4}[[:space:]][0-9]{2}:[0-9]{2})(.*)'
rcentrale='(.*)(PULSAR[[:space:]][0-9])(.*)'
rconcentratore='(.*)(\([0-9]{3}\))(.*)'
rseriale='(.*)([0-9]{8})(.*)'
rseriale_alt='(.*)([[:punct:]][0-9]{7})(.*)'
rvarco='(.*)(H\([0-9]{2}\))(.*)'

qutenzeq='(.*)(' #1-2
qutenzeq+='([[:graph:]][[:space:]]ADMIN1[[:space:]][[:graph:]])|' #3
qutenzeq+='([[:graph:]][[:space:]]ADMIN2[[:space:]][[:graph:]])|' #4
qutenzeq+='([[:graph:]][[:space:]]VISUAL[[:space:]][[:graph:]])' #5
qutenzeq+=')(.*)' #6
qutenzeq_max=6

utenze='(.*)(' #1-2
utenze+='(ADMIN1)|' #3
utenze+='(ADMIN2)|' #4
utenze+='(VISUAL)' #5
utenze+=')(.*)' #6
utenze_max=6

reventi_abilitato='(.*)(ABILITATO)(.*)'
reventi_dis='(.*)(DIS)(.*)'

reventi_durata='(.*)([[:graph:]]durata[[:space:]][[:alnum:]]{2,4}[[:punct:]]{1,2}[[:alnum:]]{2,3}[[:punct:]]{1,2}[[:alnum:]]{2,3}[[:graph:]])(.*)'
reventi_statolettore='(.*)(Stato[[:space:]]Lettore)(.*)'

reventi='(.*)(' # 1-2
reventi+='(Scasso[[:space:]]varco)|' #3
reventi+='(Varco[[:space:]]chiuso)|' #4
reventi+='(Varco[[:space:]]non[[:space:]]chiuso)|' #5
reventi+='(Varco[[:space:]]non[[:space:]]aperto)|' #6
reventi+='(Transito[[:space:]]effettuato)|' #7
reventi+='(Transito[[:space:]]non[[:space:]]consentito)|' #8
reventi+='(Transito[[:space:]]lettore[[:space:]]disabilitato)|' #9
reventi+='(Tessera[[:space:]]inesistente)|' #10
reventi+='(Caduta[[:space:]]Linea[[:punct:]]?)|' #11
reventi+='(Linea[[:space:]]Mini[[:space:]]Pulsar[[:punct:]])|' #12

reventi+='(Allarmi[[:space:]]Acquisiti[[:graph:]].*[[:graph:]]{2}[[:space:]])|' #13
reventi+='(Allarme[[:space:]]Tamper)|' #14

reventi+='(Richiesta[[:space:]]Invio[[:space:]]Programmazione[[:space:]][[:punct:]][[:space:]])|' #15
reventi+='(Fine[[:space:]]invio[[:space:]]dati[[:space:]]di[[:space:]]programmazione[[:punct:]])|' #16
reventi+='(Comando[[:space:]]Cambio)|' #17
reventi+='(Richiesta[[:space:]]Comando[[:space:]]Apertura[[:space:]]Varco)|' #18
reventi+='(Apertura[[:space:]]varco[[:space:]]Console[[:punct:]])|' #19
reventi+='(Allarme[[:space:]]ingresso[[:space:]][0-9])|' #20
reventi+='(Fine[[:space:]]transito)|' #21
reventi+='(Ripristino[[:space:]]Linea)|' #22
reventi+='(Tastiera[[:space:]]Abilitata[[:punct:]])' #23
reventi+=')(.*)' #24
reventi_max=24

rdirezioni='(.*)((ENTRATA)|(USCITA))(.*)'
rdirezioni_max=5

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
					unset buffer data centrale seriale evento varco direzione ospite eventi_dis eventi_abilitato eventi_durata utenza eventi_statolettore
					printf -v buffer "$target"
					
					# trash
					[[ $buffer =~ $rconcentratore ]] && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					
					# componenti evento
					[[ $buffer =~ $qutenzeq ]] && utenza=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$qutenzeq_max]}
					[[ $buffer =~ $utenze ]] && utenza=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$utenze_max]}
					
					[[ $buffer =~ $reventi_abilitato ]] && eventi_abilitato=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_dis ]] && eventi_dis=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					
					[[ $buffer =~ $reventi_durata ]] && eventi_durata=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_statolettore ]] && eventi_statolettore=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					
					# contents
					[[ $buffer =~ $rdata ]] && data=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rcentrale ]] && centrale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rseriale ]] && seriale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rseriale_alt ]] && seriale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rvarco ]] && varco=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi ]] && evento=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$reventi_max]}
					[[ $buffer =~ $rdirezioni ]] && direzione=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$rdirezioni_max]}
					
					# concateno i componenti
					# schema: EVENTO STATOLETTORE [DIS]ABILITATO DURATA
					
					if [[ -n $utenza ]]; then			
						if [[ -n $ospite ]]; then
							printf -v ospite "%s %s" "$ospite" $(echo "$utenza" | tr -d '[|]')
						else
							printf -v ospite "%s" $(echo "$utenza" | tr -d '[|]')
						fi
					fi
					
					[[ -n $eventi_statolettore ]] && printf -v evento "%s %s" "$evento" "$eventi_statolettore"
					
					if [[ -n $eventi_dis ]]; then 
						printf -v evento "%s %s%s" "$evento" "$eventi_dis" "$eventi_abilitato"
					elif [[ -n $eventi_abilitato ]]; then 
						printf -v evento "%s %s" "$evento" "$eventi_abilitato"
					fi
					
					[[ -n $eventi_durata ]] && printf -v evento "%s %s" "$evento" "$eventi_durata"
					
					# clean buffer from punctuation and whitespaces
					#echo -n "buffer before: length"${#buffer}" ["$buffer"] <----> " >> $TODO
					printf -v buffer "%s" "$(remove_punctuation $(combined_whitespaces "$buffer"))"
									
					mycall="CALL input_serchio('$data','$centrale','$seriale','$evento','$varco','$direzione','$ospite','$checksum');"
					#echo "after: length"${#buffer}" ["$buffer"] | "$target" | "$mycall"" >> $TODO
					
					#mycall="CALL input_serchio($(perl ser_parse_core.pl "$target"),'$checksum');"
					
					echo "$mycall" >> $LOG
									
					if [ ! -z "$buffer" ]; then
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
