#!/bin/bash

sudo mount "/mnt/REPORT/"
sudo mount "/mnt/dcserver1/"

#SRC="/mnt/REPORT/{Serchio,Winwatch}/$(date +'%Y')"
#DST="/mnt/dcserver1/REPORT/Export/{Serchio,Winwatch}/$(date +'%Y')"

SRC="/mnt/REPORT/Serchio/$(date +'%Y')"
DST="/mnt/dcserver1/REPORT/Export/Serchio/"
sudo rsync -azv $SRC $DST

SRC="/mnt/REPORT/WinWatch/$(date +'%Y')"
DST="/mnt/dcserver1/REPORT/Export/WinWatch/"
sudo rsync -azv $SRC $DST

sudo umount "/mnt/REPORT/"
sudo umount "/mnt/dcserver1/"

