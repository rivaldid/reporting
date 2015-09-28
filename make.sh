#!/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/log.log"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

echo "--> Carico la base" >> $LOG
$reporting_db -e "source $PREFIX/base.sql \W;" >> $LOG

echo "--> Carico le funzioni" >> $LOG
$reporting_db -e "source $PREFIX/functions.sql \W;" >> $LOG

echo "--> Carico le procedure in ingresso dati" >> $LOG
$reporting_db -e "source $PREFIX/input.sql \W;" >> $LOG

echo "--> Carico le viste" >> $LOG
$reporting_db -e "source $PREFIX/view.sql \W;" >> $LOG