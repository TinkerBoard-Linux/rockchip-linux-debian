#!/bin/bash

$(sudo su -c "echo 123 >  /sys/class/gpio/export")
$(sudo su -c "echo out > /sys/class/gpio/gpio123/direction")
$(sudo su -c "echo 0 > /sys/class/gpio/gpio123/value")
sleep 4
$(sudo su -c "echo 1 >  /sys/class/gpio/gpio123/value")
sleep 0.5
$(sudo su -c "echo 15 > /sys/class/gpio/export")
$(sudo su -c "echo out > /sys/class/gpio/gpio15/direction")
$(sudo su -c "echo 0 > /sys/class/gpio/gpio15/value")
sleep 1
result1=$(cat /sys/class/gpio/gpio15/value)
#echo "result1: $result1"
if [ "$result1" == "0" ]; then
	$(sudo su -c "echo 1 > /sys/class/gpio/gpio15/value")
	sleep 3
	result2=$(cat /sys/class/gpio/gpio15/value)
	#echo "result2: $result2"
	if [ "$result2" == "1" ]; then
		echo "PASS"
		$(sudo su -c "echo 0 > /sys/class/gpio/gpio15/value")
		$(sudo su -c "echo 15 > /sys/class/gpio/unexport")
		$(sudo su -c "echo 123 > /sys/class/gpio/unexport")
	else
		echo "FAIL"
	fi
else
	echo "FAIL"
fi
