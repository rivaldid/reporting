#!/bin/bash

FILE_PASS="/home/vilardid/account_ad.txt"

PREFIX="/home/vilardid/reporting"
source "$PREFIX/config.sh"

echo "==> Step1: Sync password da locale a remoto"
scp "$FILE_PASS" vilardid@dcserver2:"$FILE_PASS"

echo "==> Step2: Sync report da rto1y11c013 a remoto"
. /home/vilardid/reporting/sync_report.sh

echo "==> Step3: Parse data su remoto"
ssh vilardid@dcserver2 "/home/vilardid/reporting/population.sh"

echo "==> Step4: Parse ADC su locale"
. /home/vilardid/reporting/adc_parse.sh --skip

#echo "==> Step5: Sync risultati ADC Parse su remoto"
#scp "$ADC_HISTORY" vilardid@dcserver2:"$ADC_HISTORY"
#ssh vilardid@dcserver2 "pv \"$ADC_HISTORY\" | mysql \"$MYARGS\" -D reporting"