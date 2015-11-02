#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/population.log"

cd $PREFIX
if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

echo "*** BEGIN " $(date) "***" >> $LOG

echo "==> winparse" >> $LOG
{ time ./win_parse.sh >> $LOG; } 2>> $LOG
if [ $? -eq 0 ]; then
	echo "--> winparse terminato con successo" >> $LOG
else
	echo "--> winparse terminato senza lavoro" >> $LOG
fi

echo "==> serparse" >> $LOG
{ time ./ser_parse.sh >> $LOG; } 2>> $LOG
if [ $? -eq 0 ]; then
	echo "--> serparse terminato con successo" >> $LOG
else
	echo "--> serparse terminato senza lavoro" >> $LOG
fi

echo "*** END " $(date) "***" >> $LOG

cat $LOG | mail -s "script population reporting db" vilardid@localhost