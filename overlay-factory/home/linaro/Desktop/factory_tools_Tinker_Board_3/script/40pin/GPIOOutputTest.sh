#!/bin/bash -e

Output="$1"
PULL="$2"

echo "output=${Output}"

echo ${Output} > /sys/class/gpio/unexport
sleep 1
echo ${Output} > /sys/class/gpio/export
sleep 1

#set output low
echo out > /sys/class/gpio/gpio"${Output}"/direction
echo ${PULL} > /sys/class/gpio/gpio"${Output}"/value

FromStatusL=`cat /sys/class/gpio/gpio"${Output}"/value`

echo "GPIO ${Output} pull ${PULL} => read value=$FromStatusL"

#sleep 2
#set output high
#echo out > /sys/class/gpio/gpio"${Output}"/direction
#echo 1 > /sys/class/gpio/gpio"${Output}"/value
#echo "=======High========"
#echo "pin${Output}(output)"
#FromStatusH=`cat /sys/class/gpio/gpio"${Output}"/value`

#echo "pull high => read value=$FromStatusH"
