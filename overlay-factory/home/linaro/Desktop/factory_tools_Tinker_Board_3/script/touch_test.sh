#!/bin/bash

TOUCH_INPUT_EVENT=/dev/input/event1

if [ ! -e ${HID_INPUT_EVENT} ]; then
	echo "FAIL"
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
		exit 0
	fi
done < <(evtest --grab ${TOUCH_INPUT_EVENT})

echo "FAIL"
exit 1
