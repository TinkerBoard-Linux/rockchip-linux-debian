#!/bin/bash

name=$(sudo su -c "cat /sys/class/hwmon/hwmon4/name")

if [ "$name" == "pwmfan" ]; then
	$(sudo su -c "echo 100 > /sys/class/hwmon/hwmon4/pwm_dutycycle")
	$(sudo su -c "echo 10000000 > /sys/class/hwmon/hwmon4/pwm_period")
	sleep 1
	pwm_period=$(sudo su -c "cat /sys/class/hwmon/hwmon4/pwm_period")
	pwm_freq=$((1000000000/$pwm_period))
	echo "PWM Freq:" $pwm_freq
	sleep 1
	rpm=$(sudo su -c "cat /sys/class/hwmon/hwmon4/fan_input")
	echo "RPM:" $rpm
	freq=$(($rpm/30))
	echo "Freq:" $freq
	if [[ $freq -ge 95 ]] && [[ $freq -le 105 ]]; then
		echo "PASS"
	else
		echo "FAIL, error freq number"
	fi
else
	echo "FAIL, can't get pwmfan name"
fi
