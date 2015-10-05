#!/usr/bin/bash

PREFIX="/home/vilardid/reporting"

cd $PREFIX
echo -n "--> winparse..."
./win_parse.sh
if [ $? -eq 0 ]; then
	echo "ok"
else
	echo "fail"
fi

