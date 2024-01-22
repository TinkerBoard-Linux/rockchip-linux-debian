#!/bin/bash -e

Output="$1"
Input="$2"

echo "output=${Output} => input=${Input}"
#set output low
echo out > /sys/class/gpio/gpio"${Output}"/direction
echo 0 > /sys/class/gpio/gpio"${Output}"/value
#echo "=======Low========"
#echo "pin${Output}(output)"
FromStatusL=`cat /sys/class/gpio/gpio"${Output}"/value`
#set input
echo in > /sys/class/gpio/gpio"${Input}"/direction
ToStatusL=`cat /sys/class/gpio/gpio"${Input}"/value`

#set output high
echo out > /sys/class/gpio/gpio"${Output}"/direction
echo 1 > /sys/class/gpio/gpio"${Output}"/value
#echo "=======High========"
#echo "pin${Output}(output)"
FromStatusH=`cat /sys/class/gpio/gpio"${Output}"/value`

#get input
ToStatusH=`cat /sys/class/gpio/gpio"${Input}"/value`

if [ $FromStatusL -eq 0 ] && [ $ToStatusL -eq 0 ] && [ $FromStatusH -eq 1 ] && [ $ToStatusH -eq 1 ]; then
    echo "PASS"
else
    echo "FAIL"
fi

