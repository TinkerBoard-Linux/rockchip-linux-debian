#!/bin/bash

DIOIN=472
DIOOUTPUT=503

function gpio {
    GPIO=$1
    ACTION=$2

    case $ACTION in
    acquire)
        echo $GPIO > /sys/class/gpio/export
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
if [ "$result" == "0" ]; then
        echo "FAIL"
        exit
fi

gpio $DIOOUTPUT low
result=$(cat /sys/class/gpio/gpio${DIOIN}/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

echo "PASS"



