#!/bin/bash

thermal=$(cat /sys/bus/i2c/devices/7-0049/hwmon/hwmon*/temp1_input)

echo "$thermal"
