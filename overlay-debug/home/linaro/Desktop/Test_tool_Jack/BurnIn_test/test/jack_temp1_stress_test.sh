#!/bin/bash
TAG=JACK_TEMP1
logfile=$1
pass_cnt=0
fail_cnt=0
DEV1_TEMP_PATH=/sys/bus/i2c/devices/7-0049/hwmon/hwmon*/temp1_input

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	test_path=`cat $DEV1_TEMP_PATH`
	if [ -n "$test_path" ]; then
		dev1_temp=`cat  $DEV1_TEMP_PATH`
		if [ -n "$dev1_temp" ]; then
			dev1_temp=`awk 'BEGIN{printf "%.2f\n",('$dev1_temp'/1000)}'`
			echo "Temperature sensor is working properly. Current tempature is: $dev1_temp 'C"
			log "Temperature sensor is working properly. Current tempature is: $dev1_temp 'C"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"
			fail_cnt=0

		else
			echo "Temperature sensor failed to return valid dev1_temp."
			log "Temperature sensor failed to return valid dev1_temp."
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
		

	else
		echo "Temperature sensor device not found."
		log  "Temperature sensor device not found."
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi	
	if [ "$fail_cnt" -ge 6  ]; then
		log "Temperature sensor pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
	sleep 2
done
