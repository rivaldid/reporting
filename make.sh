#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/make.log"
DUMPFILE=$PREFIX"/dumpfile.sql"
MYARGS="-ureporting -preportuser -D reporting"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

echo "--> Dumping del db" >> $LOG
mysqldump -ureporting -preportuser reporting > $DUMPFILE

echo "--> Carico la base" >> $LOG
mysql $MYARGS -e "source $PREFIX/base.sql \W;" >> $LOG

echo "--> Carico le funzioni" >> $LOG
mysql $MYARGS -e "source $PREFIX/functions.sql \W;" >> $LOG

echo "--> Carico le procedure in ingresso dati" >> $LOG
mysql $MYARGS -e "source $PREFIX/input.sql \W;" >> $LOG

echo "--> Carico le viste" >> $LOG
mysql $MYARGS -e "source $PREFIX/view.sql \W;" >> $LOG

echo "--> Carico alcuni dati " >> $LOG
mysql $MYARGS -e "source $PREFIX/dati.sql \W;" >> $LOG

echo "--> Ripristino il dump" >> $LOG
mysql $MYARGS -e "source $DUMPFILE \W;" >> $LOG
rm $DUMPFILE