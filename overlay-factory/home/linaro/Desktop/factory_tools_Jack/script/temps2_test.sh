#!/bin/bash

thermal=$(cat /sys/bus/i2c/devices/7-0048/hwmon/hwmon*/temp1_input)

echo "$thermal"
