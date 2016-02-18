#!/bin/bash

# basic configs

# passwords
FILE_PASSWORD="/home/vilardid/account_db.txt"
source "$FILE_PASSWORD"

# mysql arguments user
MYARGS="-h 127.0.0.1 -P 3306 -ureporting -p$pass_reporting -D reporting"
# mysql arguments root
MYARGS1="-h 127.0.0.1 -P 3306 -uroot -p$pass_root"
# mysql arguments dump
MYARGS2="-h 127.0.0.1 -P 3306 -ureporting -p$pass_reporting reporting"

# history logfile
WIN_HISTORY="$PREFIX/win_parse.history.log"
SER_HISTORY="$PREFIX/ser_parse.history.log"
ADC_HISTORY="$PREFIX/adc_parse.history.log"