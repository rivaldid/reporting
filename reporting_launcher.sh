#!/bin/bash

echo -n "fase1... "
. /home/vilardid/reporting/sync_report.sh
echo "ok!"

echo -n "fase2... "
ssh vilardid@dcserver2 "/home/vilardid/reporting/population.sh"
echo "ok!"
