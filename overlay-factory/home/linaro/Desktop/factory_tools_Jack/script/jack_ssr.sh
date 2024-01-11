#!/bin/bash

DIOIN=463
DIOOUTPUT=470
POWER=491

function gpio {
    GPIO=$1
    ACTION=$2

    case $ACTION in
    acquire)
	if [[ ! -d "/sys/class/gpio/gpio${GPIO}/" ]]; then
                echo $GPIO > /sys/class/gpio/export
	fi
        ;;
    release)
        echo $GPIO > /sys/class/gpio/unexport
        ;;
    output)
        echo out > /sys/class/gpio/gpio$GPIO/direction
        ;;
    input)
        echo in > /sys/class/gpio/gpio$GPIO/direction
        ;;
    high)
        echo 1 > /sys/class/gpio/gpio$GPIO/value
        ;;
    low)
        echo 0 > /sys/class/gpio/gpio$GPIO/value
        ;;
    *)
        echo "Unsupported Parameter"
        ;;
    esac
    sleep 1
}

gpio $DIOIN acquire
gpio $DIOIN input
    
gpio $DIOOUTPUT acquire
gpio $DIOOUTPUT output

gpio $DIOOUTPUT high
result=$(cat /sys/class/gpio/gpio${DIOIN}/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

eeprom=$(i2cdetect -y 5 | grep 58)
if [ ! "$eeprom" ]; then
	echo "FAIL"
	exit
fi

gpio $DIOOUTPUT low
result=$(cat /sys/class/gpio/gpio${DIOIN}/value)
if [ "$result" == "0" ]; then
        echo "FAIL"
        exit
fi

eeprom=$(i2cdetect -y 5 | grep 58)
if [ -n "$eeprom" ]; then
	echo "FAIL"
	exit
fi

echo "PASS"



