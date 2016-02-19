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

# history logfile
WIN_HISTORY="$PREFIX/win_parse.history.log"
SER_HISTORY="$PREFIX/ser_parse.history.log"
ADC_HISTORY="$PREFIX/adc_parse.history.log"