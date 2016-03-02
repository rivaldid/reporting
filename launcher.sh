#!/bin/bash

FILE_PASS="/home/vilardid/account_ad.txt"

echo "==> Sync password to remote server"
scp "$FILE_PASS" vilardid@dcserver2:"$FILE_PASS"
echo "==> Sync password to remote server done!"

echo "==> Sync server"
. /home/vilardid/reporting/sync_report.sh
echo "==> Sync server done!"

echo "==> Parse data"
ssh vilardid@dcserver2 "/home/vilardid/reporting/population.sh"
echo "==> Parse data done!"
