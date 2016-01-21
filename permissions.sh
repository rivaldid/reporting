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

# user
mysql $MYARGS -e "source administration.sql \W;" >> $LOG
mysql $MYARGS -e "CALL administration.drop_user('webreporting');" >> $LOG
mysql $MYARGS -e "CREATE USER 'webreporting'@'%' IDENTIFIED BY 'webuser';" >> $LOG

# private
mysql $MYARGS -e "GRANT EXECUTE ON FUNCTION reporting.html_unencode TO 'webreporting'@'%'" >> $LOG

# permissions
mysql $MYARGS -e "GRANT SELECT ON reporting.SERCHIO TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS -e "GRANT SELECT ON reporting.SERCHIO_OSPITI TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS -e "GRANT SELECT ON reporting.BADGES TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS -e "GRANT SELECT ON reporting.WINWATCH TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS -e "GRANT SELECT ON reporting.ADC TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS -e "GRANT SELECT ON magazzino.vserv_trace TO 'webreporting'@'%';" >> $LOG

# public
mysql $MYARGS -e "GRANT EXECUTE ON PROCEDURE reporting.PASSAGGI TO 'webreporting'@'%';" >> $LOG

# end
mysql $MYARGS -e "FLUSH PRIVILEGES;" >> $LOG