#!/bin/bash

echo "Setting the rtc$1 for suspend/resume test"
echo 0 > /sys/class/rtc/rtc$1/wakealarm
echo +30 > /sys/class/rtc/rtc$1/wakealarm
#echo -n mem > /sys/power/state
pm-suspend
