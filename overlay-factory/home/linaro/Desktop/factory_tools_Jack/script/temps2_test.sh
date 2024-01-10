#!/bin/bash

thermal=$(cat /sys/class/hwmon/hwmon6/temp1_input)

echo "$thermal"
