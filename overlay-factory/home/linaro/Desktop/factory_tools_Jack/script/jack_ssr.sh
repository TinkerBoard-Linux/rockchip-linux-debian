#!/bin/bash

DIOIN=483
DIOOUTPUT=470
DIO5_OUT=464
DIO5_IN=497
DIO5_POWER=481

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

gpio $DIO5_IN acquire
gpio $DIO5_IN input

gpio $DIO5_OUT acquire
gpio $DIO5_OUT output
gpio $DIO5_OUT low

gpio $DIO5_POWER acquire
gpio $DIO5_POWER output
gpio $DIO5_POWER high

gpio $DIOOUTPUT acquire
gpio $DIOOUTPUT output

gpio $DIOOUTPUT high
result=$(cat /sys/class/gpio/gpio${DIOIN}/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

result=$(cat /sys/class/gpio/gpio${DIO5_IN}/value)
if [ "$result" == "0" ]; then
        echo "FAIL"
        exit
fi

gpio $DIOOUTPUT low
result=$(cat /sys/class/gpio/gpio${DIOIN}/value)
if [ "$result" == "0" ]; then
        echo "FAIL"
        exit
fi

result=$(cat /sys/class/gpio/gpio${DIO5_IN}/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

echo "PASS"



