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


	sudo $i2cset -f -y 7 0x50 0xff 0x01
	read_value=`sudo $i2cget -f -y 7 0x50 0xff`

	echo "read_value=$read_value"

	int_1=0x01
	if [ $read_value == $int_1 ]
	then
		log "Read/Write value SAME"
		((pass_cnt+=1))
		log "pass_cnt=$pass_cnt"
	else
		log "Read/Write value Not SAME"
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi
	sleep 2
		
	sudo $i2cset -f -y 7 0x50 0xff 0x02
	read_value=`sudo $i2cget -f -y 7 0x50 0xff`

	echo "read_value=$read_value"

	int_2=0x02
	if [ $read_value == $int_2 ]
	then
		log "Read/Write value SAME"
		((pass_cnt+=1))
		log "pass_cnt=$pass_cnt"
	else
		log "Read/Write value Not SAME"
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi
		
	sleep 2
	if [ "$fail_cnt" -ge 6  ]; then
		log "rtc pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
done	
