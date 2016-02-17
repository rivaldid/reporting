#!/bin/bash
# USAGE ./make.sh --reset --history
# --history force reload data after --reset

PREFIX="/home/vilardid/reporting"
source "$PREFIX/config.sh"

LOG="$PREFIX/make.log"
DUMPFILE="$PREFIX/dumpfile.sql"

reset=false
history=false
[[ "$1" == "--help" ]] && { echo "Arguments: [--reset [--history]]"; exit; }
[[ "$1" == "--reset" ]] && reset=true
[[ "$2" == "--history" ]] && history=true

cd $PREFIX
[[ -f $LOG ]] && rm $LOG
touch $LOG

[[ -f $WIN_HISTORY ]] || touch $WIN_HISTORY
[[ -f $SER_HISTORY ]] || touch $SER_HISTORY
[[ -f $ADC_HISTORY ]] || touch $ADC_HISTORY

echo "*** BEGIN " $(date) "***" >> $LOG

if [ $reset = false ]; then
	echo "--> Dumping del db" >> $LOG
	mysqldump -ureporting -p"$pass_reporting" reporting > $DUMPFILE
else
	echo "--> NO DUMP DB" >> $LOG
fi

echo "--> Utenza con relativi permessi" >> $LOG
mysql $MYARGS1 -e "source administration.sql \W;" >> $LOG
mysql $MYARGS1 -e "CALL administration.drop_user('reporting',@res); SELECT @res;" >> $LOG
mysql $MYARGS1 -e "CREATE USER 'reporting'@'%' IDENTIFIED BY '$pass_reporting';" >> $LOG
mysql $MYARGS1 -e "GRANT ALL PRIVILEGES ON reporting.* TO 'reporting'@'%';" >> $LOG
mysql $MYARGS1 -e "FLUSH PRIVILEGES;" >> $LOG

echo "--> Carico la base" >> $LOG
mysql $MYARGS -e "source $PREFIX/base.sql \W;" >> $LOG

echo "--> Carico il decoder html" >> $LOG
mysql $MYARGS -e "source $PREFIX/myhtmldecode.sql \W;" >> $LOG

echo "--> Carico le funzioni" >> $LOG
mysql $MYARGS -e "source $PREFIX/functions.sql \W;" >> $LOG

echo "--> Carico le procedure in ingresso dati" >> $LOG
mysql $MYARGS -e "source $PREFIX/input.sql \W;" >> $LOG

echo "--> Carico le procedure in eliminazione dati" >> $LOG
mysql $MYARGS -e "source $PREFIX/uninput.sql \W;" >> $LOG

echo "--> Carico le viste" >> $LOG
mysql $MYARGS -e "source $PREFIX/view.sql \W;" >> $LOG

echo "--> Carico alcuni dati " >> $LOG
mysql $MYARGS -e "source $PREFIX/dati.sql \W;" >> $LOG

if [ $reset = false ]; then
	echo "--> Ripristino il dump" >> $LOG
	#mysql $MYARGS -e "source $DUMPFILE \W;" >> $LOG
	pv "$DUMPFILE" | mysql $MYARGS >> $LOG
	rm $DUMPFILE
fi

if [ $history = true ]; then
	echo "--> Ricarico gli archivi" >> $LOG

	echo "--> WinWatch" >> $LOG
	echo "--> WinWatch"
	#echo -n "--> Winwatch..."
	#mysql $MYARGS -e "source $WIN_HISTORY \W;" >> $LOG
	#echo "done"
	pv "$WIN_HISTORY" | mysql $MYARGS >> $LOG

	echo "--> Serchio" >> $LOG
	echo "--> Serchio"
	#echo -n "--> Serchio..."
	#mysql $MYARGS -e "source $SER_HISTORY \W;" >> $LOG
	#echo "done"
	pv "$SER_HISTORY" | mysql $MYARGS >> $LOG

	echo "--> ADC" >> $LOG
	echo "--> ADC"
	#echo -n "--> ADC..."
	#mysql $MYARGS -e "source $ADC_HISTORY \W;" >> $LOG
	#echo "done"
	pv "$ADC_HISTORY" | mysql $MYARGS >> $LOG

fi

echo "--> Carico il routing" >> $LOG
mysql $MYARGS -e "source $PREFIX/routing.sql \W;" >> $LOG

echo "--> Utente web e permessi" >> $LOG
source "$PREFIX/webpermissions.sh"

echo "*** END " $(date) "***" >> $LOG

cat $LOG | mail -s "script make reporting db" vilardid@localhost