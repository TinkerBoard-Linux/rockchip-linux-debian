#!/bin/bash -e

Output="$1"

echo "Input=${Output}"

echo ${Output} > /sys/class/gpio/unexport
sleep 1
echo ${Output} > /sys/class/gpio/export
sleep 1

#set output low
echo in > /sys/class/gpio/gpio"${Output}"/direction

FromStatusL=`cat /sys/class/gpio/gpio"${Output}"/direction`

echo "Set GPIO ${Output} input => read direction=$FromStatusL"

#sleep 2
#set output high
#echo out > /sys/class/gpio/gpio"${Output}"/direction
#echo 1 > /sys/class/gpio/gpio"${Output}"/value
#echo "=======High========"
#echo "pin${Output}(output)"
#FromStatusH=`cat /sys/class/gpio/gpio"${Output}"/value`

#echo "pull high => read value=$FromStatusH"
