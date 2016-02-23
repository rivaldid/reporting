#!/bin/bash

# basic configs

# passwords
#FILE_PASSWORD="/home/vilardid/account_db.txt"
#source "$FILE_PASSWORD"

# mysql arguments user
#MYARGS="-ureporting -p$pass_reporting"
#MYARGS="--login-path=reporting"
# mysql arguments root
#MYARGS1="-uroot -p$pass_root"
#MYARGS1="--login-path=root"

system="$(cat /etc/system-release)"
redhat='Red[[:space:]]Hat[[:space:]]Enterprise[[:space:]]Linux[[:space:]]Server'
centos='CentOS[[:space:]]Linux'

if [[ $system =~ $redhat ]]; then
	echo "Trovato sistema operativo Red Hat"
	MYARGS="--login-path=reporting"
	MYARGS1="--login-path=root"
elif [[ $system =~ $centos ]]; then
	echo "Trovato sistema operativo CentOS"
	FILE_PASSWORD="/home/vilardid/account_db.txt"
	source "$FILE_PASSWORD"
	MYARGS="-ureporting -p$pass_reporting"
	MYARGS1="-uroot -p$pass_root"
else
	echo "Sistema operativo non trovato o non compatibile"
	exit 1
fi

# archives log files
ARCHIVE="/home/vilardid/.reporting"
mkdir -p "$ARCHIVE"
WIN_HISTORY="$ARCHIVE/win_parse.archive.log"
SER_HISTORY="$ARCHIVE/ser_parse.archive.log"
ADC_HISTORY="$ARCHIVE/adc_parse.archive.log"