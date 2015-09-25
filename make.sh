#!/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/log.log"

if [ -f $LOG ]; then rm $LOG; fi
touch $LOG

echo "--> Carico la base" >> $LOG
$reporting_db -e "source $PREFIX/base.sql \W;" >> $LOG
