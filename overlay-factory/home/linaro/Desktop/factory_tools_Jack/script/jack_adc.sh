#!/bin/bash

ADC1_RAW=$(cat /sys/bus/iio/devices/iio\:device0/in_voltage6_raw)
ADC2_RAW=$(cat /sys/bus/iio/devices/iio\:device0/in_voltage7_raw)
VOL_SCALE=$(cat /sys/bus/iio/devices/iio\:device0/in_voltage_scale)
VOL_SCALE_integer=$(echo $VOL_SCALE | cut -d'.' -f1)
VOL_SCALE_decimal=$(echo $VOL_SCALE | cut -d'.' -f2)

ADC1_Vresult=$(($ADC1_RAW * ($VOL_SCALE_integer * 1000000000 + $VOL_SCALE_decimal) / 1000000000))
ADC2_Vresult=$(($ADC2_RAW * ($VOL_SCALE_integer * 1000000000 + $VOL_SCALE_decimal) / 1000000000))

echo "ADC1(mV):$ADC1_Vresult"
echo "ADC2(mV):$ADC2_Vresult"
