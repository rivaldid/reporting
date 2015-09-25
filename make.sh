#!/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/log.log"

echo "--> Carico la base" >> $LOG
$reporting_db -e "source $PREFIX/base.sql \W;" >> $LOG
