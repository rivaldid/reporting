#!/bin/bash

# basic configs

# workspace
PREFIX="/home/vilardid/reporting"

# passwords
FILE_PASSWORD="/home/vilardid/account_db.txt"
source "$FILE_PASSWORD"

# mysql arguments
MYARGS="-ureporting -p$pass_reporting -D reporting"