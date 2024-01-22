#!/bin/bash -e

#a=0

#while [ $a -lt 100000000 ]
#do
#	echo "times: $a"
#	a=`expr $a + 1`
sudo su -c "python GPIOTest.py 1"
#done
#read -n 1 -p "Press any key to continue.." INP
#if [ $INP != '' ] ;then
#	echo -ne '\b \n'
#fi
