#!/bin/bash

echo "==> Sync server"
. /home/vilardid/reporting/sync_report.sh
echo "==> Sync server done!"

echo "==> Parse data"
ssh vilardid@dcserver2 "/home/vilardid/reporting/population.sh"
echo "==> Parse data done!"
