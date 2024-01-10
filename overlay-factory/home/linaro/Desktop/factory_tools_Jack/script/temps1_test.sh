#!/bin/bash

thermal=$(cat /sys/class/hwmon/hwmon5/temp1_input)

echo "$thermal"
