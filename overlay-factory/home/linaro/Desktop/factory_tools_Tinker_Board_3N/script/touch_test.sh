#!/bin/bash

NumberOfEvents=$(ls /dev/input | grep -o "event[0-9]" | wc -l)
DevExist=0

if [ "$1" == "" ]; then
	DevName="eGalaxTouch"
else
	DevName=$1
fi

i=0
while [ $i -lt $NumberOfEvents ]; do
	Name=$(cat /sys/class/input/event$i/device/name)
	if [[ "$Name" == *"$DevName"* ]]; then
		DevExist=1
		break
	fi
	let i=i+1
done

if [ "$DevExist" == "0" ]; then
	echo "no touch device"
	exit 1
fi

TOUCH_INPUT_EVENT=/dev/input/event$i

if [ ! -e ${TOUCH_INPUT_EVENT} ]; then
	echo "no touch event path"
	exit 1
fi

while read -t 5 -r line; do
	CODE=`echo $line | awk -F "," '{print $3}'`
	VALUE=`echo $line | awk -F "," '{print $4}'`
	if [ "$CODE" == " code 53 (ABS_MT_POSITION_X)" ]; then
		ABS_X=$VALUE
	elif [ "$CODE" == " code 54 (ABS_MT_POSITION_Y)" ]; then
		ABS_Y=$VALUE
	fi

	if [ -n "$ABS_X" ] && [ -n "$ABS_Y" ]; then
		x=`echo $ABS_X | awk -F " " '{print $2}'`
		y=`echo $ABS_Y | awk -F " " '{print $2}'`
		echo "$x,$y"
		killall evtest
		exit 0
	fi
done < <(evtest --grab ${TOUCH_INPUT_EVENT})

echo "FAIL"
killall evtest
exit 1
