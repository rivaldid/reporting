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
	echo "--> winparse done" >> $LOG
else
	echo "--> winparse fail" >> $LOG
fi

echo "==> serparse" >> $LOG
{ time ./ser_parse.sh >> $LOG; } 2>> $LOG
if [ $? -eq 0 ]; then
	echo "--> serparse done" >> $LOG
else
	echo "--> serparse fail" >> $LOG
fi

echo "*** END " $(date) "***" >> $LOG

cat $LOG | mail -s "script population reporting db" vilardid@localhost