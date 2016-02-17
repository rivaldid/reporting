#!/usr/bin/bash

source "config.sh"
LOG=$PREFIX"/webpermissions.log"

MYARGS1="-uroot -p$pass_root"

cd $PREFIX
[[ -f $LOG ]] && rm $LOG
touch $LOG

#mysql $MYARGS -e "" >> $LOG

# user
mysql $MYARGS1 -e "CALL administration.drop_user('webreporting',@res); SELECT @res;" >> $LOG
mysql $MYARGS1 -e "CREATE USER 'webreporting'@'%' IDENTIFIED BY '$pass_webreporting';" >> $LOG

# permissions
mysql $MYARGS1 -e "GRANT EXECUTE ON FUNCTION reporting.html_unencode TO 'webreporting'@'%'" >> $LOG
mysql $MYARGS1 -e "GRANT SELECT ON reporting.SERCHIO TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS1 -e "GRANT SELECT ON reporting.SERCHIO_OSPITI TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS1 -e "GRANT SELECT ON reporting.BADGES TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS1 -e "GRANT SELECT ON reporting.WINWATCH TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS1 -e "GRANT SELECT ON reporting.ADC TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS1 -e "GRANT SELECT ON magazzino.vserv_trace TO 'webreporting'@'%';" >> $LOG
mysql $MYARGS1 -e "GRANT EXECUTE ON PROCEDURE reporting.PASSAGGI TO 'webreporting'@'%';" >> $LOG

# post
mysql $MYARGS1 -e "FLUSH PRIVILEGES;" >> $LOG