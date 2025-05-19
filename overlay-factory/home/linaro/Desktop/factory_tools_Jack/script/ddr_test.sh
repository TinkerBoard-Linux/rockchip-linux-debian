#!/bin/bash

MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')

if [ -d "/sys/class/devfreq/dmc/" ]; then
    echo performance > /sys/class/devfreq/dmc/governor
    DRAM_CLOCK=$(cat /sys/class/devfreq/dmc/cur_freq 2> /dev/null)
else
    DRAM_CLOCK=$(cat /sys/kernel/debug/clk/clk_scmi_ddr/clk_rate 2> /dev/null)
fi

if [ -z $DRAM_CLOCK ]; then
    echo "FAIL"
else
    echo "$MEM_TOTAL,$DRAM_CLOCK"
fi
