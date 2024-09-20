#!/bin/bash

DIOIN=146

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
    sleep 0.5
}

gpio $DIOIN acquire
gpio $DIOIN input
    
result=$(cat /sys/class/gpio/gpio${DIOIN}/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

echo "PASS"

