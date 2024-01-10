#!/bin/bash


BUSMONITEM=$1
HWMON=3

case $BUSMONITEM in
VDD_12V_CC)
    curr_input=$(cat /sys/class/hwmon/hwmon${HWMON}/curr1_input)
    in_input=$(cat /sys/class/hwmon/hwmon${HWMON}/in1_input)
    in_label=$(cat /sys/class/hwmon/hwmon${HWMON}/in1_label)
    ;;
VDD_12V_DIS)
    curr_input=$(cat /sys/class/hwmon/hwmon${HWMON}/curr2_input)
    in_input=$(cat /sys/class/hwmon/hwmon${HWMON}/in2_input)
    in_label=$(cat /sys/class/hwmon/hwmon${HWMON}/in2_label)
    ;;
AMP_PVCC)
    curr_input=$(cat /sys/class/hwmon/hwmon${HWMON}/curr3_input)
    in_input=$(cat /sys/class/hwmon/hwmon${HWMON}/in3_input)
    in_label=$(cat /sys/class/hwmon/hwmon${HWMON}/in3_label)
    ;;
*)
    echo "Unsupported Parameter"
    exit	
    ;;
esac

echo ${curr_input}","${in_input}","${in_label}
