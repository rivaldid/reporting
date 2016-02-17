#!/bin/bash

PREFIX="/home/vilardid/reporting"
source "$PREFIX/config.sh"

LOG1="$PREFIX/webpermissions.log"

MYARGS1="-uroot -p$pass_root"

cd $PREFIX
[[ -f $LOG1 ]] && rm $LOG1
touch $LOG1

echo "*** BEGIN " $(date) "***" >> $LOG1

#mysql $MYARGS -e "" >> $LOG

# user
mysql $MYARGS1 -e "CALL administration.drop_user('webreporting',@res); SELECT @res;" >> $LOG1
mysql $MYARGS1 -e "CREATE USER 'webreporting'@'%' IDENTIFIED BY '$pass_webreporting';" >> $LOG1

# permissions
mysql $MYARGS1 -e "GRANT EXECUTE ON FUNCTION reporting.html_unencode TO 'webreporting'@'%'" >> $LOG1
mysql $MYARGS1 -e "GRANT SELECT ON reporting.SERCHIO TO 'webreporting'@'%';" >> $LOG1
mysql $MYARGS1 -e "GRANT SELECT ON reporting.SERCHIO_OSPITI TO 'webreporting'@'%';" >> $LOG1
mysql $MYARGS1 -e "GRANT SELECT ON reporting.BADGES TO 'webreporting'@'%';" >> $LOG1
mysql $MYARGS1 -e "GRANT SELECT ON reporting.WINWATCH TO 'webreporting'@'%';" >> $LOG1
mysql $MYARGS1 -e "GRANT SELECT ON reporting.ADC TO 'webreporting'@'%';" >> $LOG1
mysql $MYARGS1 -e "GRANT SELECT ON magazzino.vserv_trace TO 'webreporting'@'%';" >> $LOG1
mysql $MYARGS1 -e "GRANT EXECUTE ON PROCEDURE reporting.PASSAGGI TO 'webreporting'@'%';" >> $LOG1

# post
mysql $MYARGS1 -e "FLUSH PRIVILEGES;" >> $LOG1

echo "*** END " $(date) "***" >> $LOG1

cat $LOG1 | mail -s "script webpermission" vilardid@localhost