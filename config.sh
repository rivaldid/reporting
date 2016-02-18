#!/bin/bash

# basic configs

# passwords
FILE_PASSWORD="/home/vilardid/account_db.txt"
source "$FILE_PASSWORD"

# mysql arguments user
MYARGS="-ureporting -p$pass_reporting"
#MYARGS="--login-path=reporting"
# mysql arguments root
MYARGS1="-uroot -p$pass_root"
#MYARGS1="--login-path=root"

# history logfile
WIN_HISTORY="$PREFIX/win_parse.history.log"
SER_HISTORY="$PREFIX/ser_parse.history.log"
ADC_HISTORY="$PREFIX/adc_parse.history.log"