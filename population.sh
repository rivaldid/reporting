#!/bin/bash

PREFIX="/home/vilardid/reporting"
source "$PREFIX/config.sh"

LOG="$PREFIX/population.log"

cd $PREFIX
if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

echo "*** BEGIN " $(date) "***" >> $LOG

echo "==> win_parse" >> $LOG
{ time ./win_parse.sh --skip >> $LOG; } 2>> $LOG
if [ $? -eq 0 ]; then
	echo "--> winparse terminato con successo" >> $LOG
else
	echo "--> winparse terminato senza lavoro" >> $LOG
fi

echo "==> ser_parse" >> $LOG
{ time ./ser_parse.sh --skip >> $LOG; } 2>> $LOG
if [ $? -eq 0 ]; then
	echo "--> serparse terminato con successo" >> $LOG
else
	echo "--> serparse terminato senza lavoro" >> $LOG
fi

#echo "==> adc_parse" >> $LOG
#{ time ./adc_parse.sh --skip >> $LOG; } 2>> $LOG
#if [ $? -eq 0 ]; then
#	echo "--> adcparse terminato con successo" >> $LOG
#else
#	echo "--> adcparse terminato senza lavoro" >> $LOG
#fi

echo "*** END " $(date) "***" >> $LOG

cat $LOG | mail -s "script population reporting db" vilardid@localhost