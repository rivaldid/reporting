#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"

cd $PREFIX
echo "==> winparse"
./win_parse.sh
if [ $? -eq 0 ]; then
	echo "--> winparse done"
else
	echo "--> winparse fail"
fi

