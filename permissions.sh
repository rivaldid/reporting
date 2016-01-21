#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"
LOG=$PREFIX"/permissions.log"

FILE_PASSWORD="/home/vilardid/account_db.txt"
source "$FILE_PASSWORD"
MYARGS="-uroot -p$pass_root"

cd $PREFIX
[[ -f $LOG ]] && rm $LOG
touch $LOG

#mysql $MYARGS -e "" >> $LOG

mysql $MYARGS -e "source administration.sql \W;" >> $LOG
mysql $MYARGS -e "CALL drop_user('webreporting');" >> $LOG