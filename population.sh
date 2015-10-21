#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"

cd $PREFIX

echo "==> winparse"
time ./win_parse.sh
if [ $? -eq 0 ]; then
	echo "--> winparse done"
else
	echo "--> winparse fail"
fi

echo "==> serparse"
time ./ser_parse.sh
if [ $? -eq 0 ]; then
	echo "--> serparse done"
else
	echo "--> serparse fail"
fi
