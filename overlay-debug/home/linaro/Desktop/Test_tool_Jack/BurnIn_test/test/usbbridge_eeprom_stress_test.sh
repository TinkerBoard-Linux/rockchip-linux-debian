#!/bin/bash
TAG=RTC
logfile=$1
pass_cnt=0
fail_cnt=0
i2cget=/usr/sbin/i2cget
i2cset=/usr/sbin/i2cset

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do


        eeprom=$(i2cdetect -y 7 | grep 50)
        if [ ! "$eeprom" ]; then
                log "Can't found EEPROM devices FAIL"
                ((fail_cnt+=1))
        else
                log "Found EEPROM devices PASS"
                ((pass_cnt+=1))
        fi

        sleep 2
        if [ "$fail_cnt" -ge 6  ]; then
                log "usbbridge i2c 7  eeprom pass_cnt = $pass_cnt fail_cnt $fail_cnt "
                exit
        fi
done	
