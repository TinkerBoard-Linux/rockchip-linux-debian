#!/bin/bash

for path in /sys/class/hwmon/hwmon*; do
	if [[ "pwmfan" == $(sudo su -c "cat $path/name") ]]; then
		#echo "hwmon name:" $(sudo su -c "cat $path/name")
		#echo "hwmon pathc:" $path
		$(sudo su -c "echo 100 > $path/pwm_dutycycle")
		$(sudo su -c "echo 10000000 > $path/pwm_period")
		sleep 1
		pwm_period=$(sudo su -c "cat $path/pwm_period")
		pwm_freq=$((1000000000/$pwm_period))
		echo "PWM Freq:" $pwm_freq
		sleep 1
		rpm=$(sudo su -c "cat $path/fan_input")
		#echo "RPM:" $rpm
		freq=$(($rpm/30))
		echo "Receive Freq:" $freq
		if [[ $freq -ge 95 ]] && [[ $freq -le 105 ]]; then
			echo "PASS"
			exit
		else
			echo "FAIL, error freq out of spec"
			exit
		fi
	fi
done
echo "FAIL, can't get hwmon path for pwmfan"
