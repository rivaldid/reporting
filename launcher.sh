#!/bin/bash
# Script pensato per intervenire alla sincronizzazione dei report
# da macchina file server (rto1y11co13) a server (sgedcdb01v)
# aggiornando anche la password del profilo utente.
# A regime ci sarà un utente locale quindi niente sincronizzazione password
# e report gia' sul server quindi niente sincronizzazione report,
# quindi a regime vi sara' solo il population.

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

# A REGIME SOLO POPULATION 
#echo "==> Step unico: parse report"
#. /home/vilardid/reporting/population.sh
