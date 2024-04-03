#!/bin/bash


SSR_EN=470
SSR_FB=463
CCR_12V=491

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

gpio $SSR_FB acquire
gpio $SSR_FB input

gpio $CCR_12V acquire
gpio $CCR_12V output
gpio $CCR_12V high

gpio $SSR_EN acquire
gpio $SSR_EN output
gpio $SSR_EN low

result=$(cat /sys/class/gpio/gpio${SSR_FB}/value)
if [ "$result" == "0" ]; then
        echo "FAIL"
        exit
fi

gpio $SSR_EN high
result=$(cat /sys/class/gpio/gpio${SSR_FB}/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

echo "PASS"



