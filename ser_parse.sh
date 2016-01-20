#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
REPORT="/mnt/REPORT"
TRASH_PREFIX="/mnt/REPORT/Serchio"
TEMP_DIR=$PREFIX"/TEMP"

LOG=$PREFIX"/ser_parse.log"
#TODO=$PREFIX"/ser_parse_unmatched.log"
SER_HISTORY=$PREFIX"/ser_parse.history.log"

source /home/vilardid/account_db.txt
MYARGS="-ureporting -p$pass_reporting -D reporting"

SKIPTEST=1

# regex
rdata='(.*)([0-9]{2}/[0-9]{2}/[0-9]{4}[[:space:]][0-9]{2}:[0-9]{2})(.*)'
rcentrale='(.*)(PULSAR[[:space:]][0-9])(.*)'
rconcentratore='(.*)(\([0-9]{3}\))(.*)'
rseriale='(.*)([0-9]{8})(.*)'
rseriale_alt='(.*)([[:punct:]][0-9]{7})(.*)'
rvarco='(.*)(H\([0-9]{2}\))(.*)'

rutenze='(.*)(' #1-2
rutenze+='([[:punct:]]?[[:space:]]ADMIN1[[:space:]][[:punct:]]?)|' #3
rutenze+='([[:punct:]]?[[:space:]]ADMIN2[[:space:]][[:punct:]]?)|' #4
rutenze+='([[:punct:]]?[[:space:]]VISUAL[[:space:]][[:punct:]]?)|' #5
rutenze+='([[:punct:]]?[[:space:]]POSTE[[:space:]][[:punct:]]?)|' #6
rutenze+='([[:punct:]]?[[:space:]]TEST[[:space:]][[:punct:]]?)|' #7
rutenze+='([[:punct:]]?[[:space:]]PROVA[[:space:]][[:punct:]]?)|' #8
rutenze+='([[:punct:]]?[[:space:]]ADM[[:space:]][[:punct:]]?)' #9
rutenze+=')(.*)' #10
rutenze_max=10

reventi_abilitato='(.*)(([[:space:]]|[[:punct:]])(DIS)?ABILITATO([[:space:]]|[[:punct:]]))(.*)'
reventi_durata='(.*)([[:graph:]]durata[[:space:]][[:alnum:]]{2,4}[[:punct:]]{1,2}[[:alnum:]]{2,3}[[:punct:]]{1,2}[[:alnum:]]{2,3}[[:graph:]])(.*)'
reventi_statolettore='(.*)(Stato[[:space:]]Lettore)(.*)'
reventi_varco_aperto='(.*)(VARCO[[:space:]]APERTO)(.*)'
reventi_sempre_abilitato='(.*)(([[:space:]]|[[:punct:]])SEMPRE[[:space:]]ABILITATO[[:punct:]]?)(.*)'

reventi_linee='(.*)(LINEA[[:space:]]((ON)|(OFF)))(.*)'
reventi_linee_max=6

#reventi_versione_pulsar='(.*)(PULSAR[[:space:]]v[[:punct:]][0-9]{2}[[:punct:]][0-9]{2}[[:punct:]][0-9]{2})(.*)'

reventi='(.*)(' # 1-2
reventi+='(Scasso[[:space:]]varco)|' #3
reventi+='(Varco[[:space:]]chiuso)|' #4
reventi+='(Varco[[:space:]]non[[:space:]]chiuso)|' #5
reventi+='(Varco[[:space:]]non[[:space:]]aperto)|' #6
reventi+='(Transito[[:space:]]effettuato)|' #7
reventi+='(Transito[[:space:]]non[[:space:]]consentito)|' #8
reventi+='(Transito[[:space:]]lettore[[:space:]]abilitato)|' #9
reventi+='(Transito[[:space:]]lettore[[:space:]]disabilitato)|' #10
reventi+='(Tessera[[:space:]]inesistente)|' #11
reventi+='(Tessera[[:space:]]fuori[[:space:]]orario)|' #12
reventi+='(Tessera[[:space:]]sospesa)|' #13
reventi+='(Caduta[[:space:]]Linea[[:punct:]]?)|' #14
reventi+='(Linea[[:space:]]Mini[[:space:]]Pulsar[[:punct:]])|' #15

reventi+='(Allarmi[[:space:]]Acquisiti[[:graph:]].*[[:graph:]]{2}[[:space:]])|' #16
reventi+='(Allarme[[:space:]]Tamper)|' #17

reventi+='(Richiesta[[:space:]]Invio[[:space:]]Programmazione[[:space:]][[:punct:]][[:space:]])|' #18
reventi+='(Richiesta[[:space:]]cancellazione[[:space:]]programmazione[[:space:]]totale[[:punct:]])|' #19
reventi+='(Fine[[:space:]]invio[[:space:]]dati[[:space:]]di[[:space:]]programmazione[[:punct:]])|' #20
reventi+='(Comando[[:space:]]Cambio)|' #21
reventi+='(Richiesta[[:space:]]Comando[[:space:]]Apertura[[:space:]]Varco)|' #22
reventi+='(Apertura[[:space:]]varco[[:space:]]Console[[:punct:]])|' #23
reventi+='(Chiusura[[:space:]]varco[[:space:]]Console[[:punct:]])|' #24
reventi+='(Allarme[[:space:]]ingresso[[:space:]][0-9])|' #25
reventi+='(Fine[[:space:]]transito)|' #26
reventi+='(Ripristino[[:space:]]Linea)|' #27
reventi+='(Tastiera[[:space:]]Abilitata[[:punct:]])|' #28
reventi+='(Tastiera[[:space:]]Disabilitata[[:punct:]])|' #29
reventi+='(Coda[[:space:]]Piena[[:punct:]]Comando[[:space:]]perso[[:punct:]]6D[[:punct:]])|' #30
reventi+='(HY[[:space:]][[:graph:]][0-9]{2}[[:graph:]])|' #31
reventi+='(Riposo[[:space:]]ingresso[[:space:]][0-9])' #32
reventi+=')(.*)' #33
reventi_max=33

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

#if [ -f $TODO ]; then rm $TODO; fi
#touch $TODO

[[ -f $SER_HISTORY ]] || touch $SER_HISTORY

[[ -d $TEMP_DIR ]] && rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

case "$1" in
	--help) 
		echo "Arguments: [--partial /mnt/REPORT/Serchio/foo/bar/baz.xps] OR [--skip]"
		exit
		;;
	--partial)
		PARTIAL="${2##$REPORT}"
		if [[ -z "$PARTIAL" ]]; then
			echo "Doing nothing, bye"
			exit 1 
		fi
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

# arguments: --partial /foo/bar/baz.xps
#if [[ ! -z "$1" ]]; then
#	[[ "$1" == "--help" ]] && { echo "Arguments: [--partial /mnt/REPORT/Serchio/foo/bar/baz.xps]"; exit; }
#	[[ "$1" == "--partial" ]] && PARTIAL="${2##$REPORT}" || { echo "What?"; exit; }

#	if [[ ! -z "$PARTIAL" ]]; then
#		confirm || { echo "Bye"; exit; }
#	else
#		echo "Doing nothing, bye"; exit 1
#	fi
#else
#	confirm || { echo "Bye"; exit; }
#fi


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
					unset buffer data centrale seriale evento varco direzione ospite eventi_sempre_abilitato eventi_abilitato eventi_durata utenza eventi_statolettore eventi_linee eventi_varco_aperto
					printf -v buffer "$target"

					# trash
					[[ $buffer =~ $rconcentratore ]] && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

					# pieces

					# utenze: capture 1st time. trash the 2nd
					[[ $buffer =~ $rutenze ]] && utenza=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$rutenze_max]}
					[[ $buffer =~ $rutenze ]] && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$rutenze_max]}

					[[ $buffer =~ $reventi_sempre_abilitato ]] && eventi_sempre_abilitato=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_abilitato ]] && eventi_abilitato=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

					[[ $buffer =~ $reventi_durata ]] && eventi_durata=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
					[[ $buffer =~ $reventi_statolettore ]] && eventi_statolettore=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

					[[ $buffer =~ $reventi_linee ]] && eventi_linee=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[$reventi_linee_max]}

					[[ $buffer =~ $reventi_varco_aperto ]] && eventi_varco_aperto=${BASH_REMATCH[2]} && buffer=${BASH_REMATCH[1]}${BASH_REMATCH[3]}

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
					[[ -n $eventi_abilitato ]] && printf -v evento "%s %s" "$evento" "$(string_cleanup "$eventi_abilitato")"
					[[ -n $eventi_sempre_abilitato ]] && printf -v evento "%s %s" "$evento" "$(string_cleanup "$eventi_sempre_abilitato")"
					[[ -n $eventi_durata ]] && printf -v evento "%s %s" "$evento" "$eventi_durata"
					[[ -n $eventi_varco_aperto ]] && printf -v evento "%s %s" "$evento" "$eventi_varco_aperto"

					printf -v buffer "%s" "$(string_cleanup "$buffer")"
					printf -v evento "%s" "$(combined_whitespaces "$evento")"

					# test buffer not empty to define ospite
					if [ ! -z "$buffer" ]; then

						# $filereferer: original filename
						# $target: line being processed
						# $buffer: target in processing and future ospite name

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