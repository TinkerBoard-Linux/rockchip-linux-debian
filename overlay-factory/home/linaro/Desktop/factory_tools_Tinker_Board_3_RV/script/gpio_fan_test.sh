#!/bin/bash

$(sudo su -c "echo 0 > /sys/class/hwmon/hwmon2/fan_power")
sleep 5
result1=$(cat /sys/class/hwmon/hwmon2/fan_power)
#echo "result1: $result1"
if [ "$result1" == "0" ]; then
	$(sudo su -c "echo 1 > /sys/class/hwmon/hwmon2/fan_power")
	sleep 2
	result2=$(cat /sys/class/hwmon/hwmon2/fan_power)
	#echo "result2: $result2"
	if [ "$result2" == "1" ]; then
		$(sudo su -c "echo 1 > /sys/class/hwmon/hwmon2/fan_speed")
		sleep 5
		result3=$(cat /sys/class/hwmon/hwmon2/fan_speed)
		#echo "result3: $result3"
		if [ "$result3" == "1" ]; then
			$(sudo su -c "echo 0 > /sys/class/hwmon/hwmon2/fan_speed")
			sleep 5
			result4=$(cat /sys/class/hwmon/hwmon2/fan_speed)
			#echo "result4: $result4"
			if [ "$result4" == "0" ]; then
				echo "PASS"
			else
				echo "FAIL"
			fi
		else
			echo "FAIL"
		fi
	else
		echo "FAIL"
	fi
else
	echo "FAIL"
fi
