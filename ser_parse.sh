#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX"/TEMP"

LOG=$PREFIX"/ser_parse.log"
#TODO=$PREFIX"/ser_parse_unmatched.log"
SER_HISTORY=$PREFIX"/ser_parse.history.log"

MYARGS="-H -ureporting -preportuser -D reporting"

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
qutenzeq+='([[:graph:]][[:space:]]VISUAL[[:space:]][[:graph:]])|' #5
qutenzeq+='([[:graph:]][[:space:]]POSTE[[:space:]][[:graph:]])|' #6
qutenzeq+='([[:graph:]][[:space:]]TEST[[:space:]][[:graph:]])' #7
qutenzeq+=')(.*)' #8
qutenzeq_max=8

utenze='(.*)(' #1-2
utenze+='(ADMIN1)|' #3
utenze+='(ADMIN2)|' #4
utenze+='(VISUAL)|' #5
utenze+='(POSTE)|' #6
utenze+='(TEST)' #7
utenze+=')(.*)' #8
utenze_max=8

reventi_abilitato='(.*)(ABILITATO)(.*)'
reventi_dis='(.*)(DIS)(.*)'

reventi_durata='(.*)([[:graph:]]durata[[:space:]][[:alnum:]]{2,4}[[:punct:]]{1,2}[[:alnum:]]{2,3}[[:punct:]]{1,2}[[:alnum:]]{2,3}[[:graph:]])(.*)'
reventi_statolettore='(.*)(Stato[[:space:]]Lettore)(.*)'

reventi_linee='(.*)(LINEA[[:space:]]((ON)|(OFF)))(.*)'
reventi_linee_max=6

reventi='(.*)(' # 1-2
reventi+='(Scasso[[:space:]]varco)|' #3
reventi+='(Varco[[:space:]]chiuso)|' #4
reventi+='(Varco[[:space:]]non[[:space:]]chiuso)|' #5
reventi+='(Varco[[:space:]]non[[:space:]]aperto)|' #6
reventi+='(Transito[[:space:]]effettuato)|' #7
reventi+='(Transito[[:space:]]non[[:space:]]consentito)|' #8
reventi+='(Transito[[:space:]]lettore[[:space:]]disabilitato)|' #9
reventi+='(Tessera[[:space:]]inesistente)|' #10
reventi+='(Tessera[[:space:]]fuori[[:space:]]orario)|' #11
reventi+='(Tessera[[:space:]]sospesa)|' #12
reventi+='(Caduta[[:space:]]Linea[[:punct:]]?)|' #13
reventi+='(Linea[[:space:]]Mini[[:space:]]Pulsar[[:punct:]])|' #14

reventi+='(Allarmi[[:space:]]Acquisiti[[:graph:]].*[[:graph:]]{2}[[:space:]])|' #15
reventi+='(Allarme[[:space:]]Tamper)|' #16

reventi+='(Richiesta[[:space:]]Invio[[:space:]]Programmazione[[:space:]][[:punct:]][[:space:]])|' #17
reventi+='(Fine[[:space:]]invio[[:space:]]dati[[:space:]]di[[:space:]]programmazione[[:punct:]])|' #18
reventi+='(Comando[[:space:]]Cambio)|' #19
reventi+='(Richiesta[[:space:]]Comando[[:space:]]Apertura[[:space:]]Varco)|' #20
reventi+='(Apertura[[:space:]]varco[[:space:]]Console[[:punct:]])|' #21
reventi+='(Allarme[[:space:]]ingresso[[:space:]][0-9])|' #22
reventi+='(Fine[[:space:]]transito)|' #23
reventi+='(Ripristino[[:space:]]Linea)|' #24
reventi+='(Tastiera[[:space:]]Abilitata[[:punct:]])|' #25
reventi+='(Coda[[:space:]]Piena[[:punct:]]Comando[[:space:]]perso[[:punct:]]6D[[:punct:]])|' #26
reventi+='(HY[[:space:]][[:graph:]][0-9]{2}[[:graph:]])' #27
reventi+=')(.*)' #28
reventi_max=28

rdirezioni='(.*)((ENTRATA)|(USCITA)|(INGRESSO)|(INTERNO)|(ESTERNO))(.*)'
rdirezioni_max=8

rapos='(.*)([[:graph:]]apos[[:punct:]])(.*)'

# /regex


leading_whitespaces() { printf "$1" | sed -e 's/^[[:space:]]*//'; }
trailing_whitespaces() { printf "$1" | sed -e 's/[[:space:]]*$//'; }
remove_punctuation() { printf "$1" | tr -d '[:punct:]'; }

combined_whitespaces() { leading_whitespaces "$(trailing_whitespaces "$1")"; }
string_cleanup() {
	if [[ $1 =~ $rapos ]]; then
		printf -v begin "$(leading_whitespaces "$(remove_punctuation "${BASH_REMATCH[1]}")")"
		printf -v apos "${BASH_REMATCH[2]}"
		printf -v end "$(trailing_whitespaces "$(remove_punctuation "${BASH_REMATCH[3]}")")"
		printf "%s%s%s" "$begin" "$apos" "$end"
	else
		combined_whitespaces "$(remove_punctuation "$1")"
	fi
}


[[ -f $LOG ]] && rm $LOG
touch $LOG

#if [ -f $TODO ]; then rm $TODO; fi
#touch $TODO

[[ -f $SER_HISTORY ]] || touch $SER_HISTORY

[[ -d $TEMP_DIR ]] && rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR


# arguments: --partial /foo/bar/baz.xps
[[ "$1" == "--help" ]] && { echo "Arguments: [--partial /mnt/REPORT/Serchio/foo/bar/baz.xps]"; exit; }
[[ "$1" == "--partial" ]] && PARTIAL="${2##$REPORT}"

if grep -qs "$REPORT" /proc/mounts; then
    echo "--> $REPORT mounted."
else
    echo "--> $REPORT not mounted."
	sudo mount "$REPORT"
fi

for file in $(find $REPORT$PARTIAL -name "*.xps" -type f); do

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
					unset buffer data centrale seriale evento varco direzione ospite eventi_dis eventi_abilitato eventi_durata utenza eventi_statolettore eventi_linee
					printf -v buffer "$target"

					# trash
					[[ $buffer =~ $rconcentratore ]] && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

					# pieces
					[[ $buffer =~ $qutenzeq ]] && utenza=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$qutenzeq_max]}
					[[ $buffer =~ $utenze ]] && utenza=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$utenze_max]}

					[[ $buffer =~ $reventi_abilitato ]] && eventi_abilitato=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_dis ]] && eventi_dis=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

					[[ $buffer =~ $reventi_durata ]] && eventi_durata=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_statolettore ]] && eventi_statolettore=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

					[[ $buffer =~ $reventi_linee ]] && eventi_linee=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$reventi_linee_max]}

					# contents
					[[ $buffer =~ $rdata ]] && data=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rcentrale ]] && centrale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rseriale ]] && seriale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rseriale_alt ]] && seriale=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $rvarco ]] && varco=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi ]] && evento=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$reventi_max]}
					[[ $buffer =~ $rdirezioni ]] && direzione=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$rdirezioni_max]}


					# chains
					[[ -n $utenza ]] && printf -v ospite "%s" "$(string_cleanup "$utenza")"

					[[ -n $eventi_statolettore ]] && printf -v evento "%s %s" "$evento" "$eventi_statolettore"

					[[ -n $eventi_linee ]] && printf -v evento "%s %s" "$evento" "$eventi_linee"

					if [[ -n $eventi_dis ]]; then
						printf -v evento "%s %s%s" "$evento" "$eventi_dis" "$eventi_abilitato"
					elif [[ -n $eventi_abilitato ]]; then
						printf -v evento "%s %s" "$evento" "$eventi_abilitato"
					fi

					[[ -n $eventi_durata ]] && printf -v evento "%s %s" "$evento" "$eventi_durata"

					printf -v buffer "%s" "$(string_cleanup "$buffer")"

					# test buffer not empty to define ospite
					if [ ! -z "$buffer" ]; then

						#echo "==> $filereferer" >> $TODO
						#echo "$target" >> $TODO
						#echo "$buffer" >> $TODO
						#echo "--> unmatched: $buffer" >> $LOG

						if [[ -n $ospite ]]; then

							printf -v ospite "%s %s" "$ospite" "$buffer"

						else

							printf -v ospite "%s" "$buffer"

						fi

					fi

					mycall="CALL input_serchio('$data','$centrale','$seriale','$evento','$varco','$direzione','$ospite','$checksum');"
					mysql $MYARGS -e "$mycall \W;" >> $LOG 2>&1

					echo "$mycall" >> $LOG

				fi # end parser core

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
cat "$LOG" >> "$SER_HISTORY"