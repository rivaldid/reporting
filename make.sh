#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/make.log"
DUMPFILE=$PREFIX"/dumpfile.sql"
MYARGS="-ureporting -preportuser -D reporting"

reset=false;
[ "$1" == "--reset" ] && reset=true

cd $PREFIX
if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

echo "*** BEGIN " $(date) "***" >> $LOG

if [ $reset = false ]; then
	echo "--> Dumping del db" >> $LOG
	mysqldump -ureporting -preportuser reporting > $DUMPFILE
fi

echo "--> Carico la base" >> $LOG
mysql $MYARGS -e "source $PREFIX/base.sql \W;" >> $LOG

echo "--> Carico il decoder html" >> $LOG
mysql $MYARGS -e "source $PREFIX/myhtmldecode.sql \W;" >> $LOG

echo "--> Carico le funzioni" >> $LOG
mysql $MYARGS -e "source $PREFIX/functions.sql \W;" >> $LOG

echo "--> Carico le procedure in ingresso dati" >> $LOG
mysql $MYARGS -e "source $PREFIX/input.sql \W;" >> $LOG

echo "--> Carico le viste" >> $LOG
mysql $MYARGS -e "source $PREFIX/view.sql \W;" >> $LOG

echo "--> Carico alcuni dati " >> $LOG
mysql $MYARGS -e "source $PREFIX/dati.sql \W;" >> $LOG

if [ $reset = false ]; then
	echo "--> Ripristino il dump" >> $LOG
	mysql $MYARGS -e "source $DUMPFILE \W;" >> $LOG
	rm $DUMPFILE
fi

echo "--> Carico il routing" >> $LOG
mysql $MYARGS -e "source $PREFIX/routing.sql \W;" >> $LOG

echo "*** END " $(date) "***" >> $LOG

cat $LOG | mail -s "script make reporting db" vilardid@localhost