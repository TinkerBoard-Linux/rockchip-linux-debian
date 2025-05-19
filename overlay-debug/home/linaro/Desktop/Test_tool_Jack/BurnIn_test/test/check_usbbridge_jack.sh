#!/bin/bash
TAG=USBBRIDGE_JACK
logfile=$1
usbbridge_pass_cnt=0
usbbridge_fail_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	lsusb|grep "2c42:1222"
	if [ "$?" == "0" ]; then
		log "Found usb bridge Fintek U1U F75115 AA88."
		((usbbridge_pass_cnt+=1))
		usbbridge_fail_cnt=0
		log "usbbridge_pass_cnt=$usbbridge_pass_cnt"
	else
		log "Can not found usb bridge Fintek U1U F75115 AA88."
		((usbbridge_fail_cnt+=1))
		log "usbbridge_fail_cnt=$usbbridge_fail_cnt"
	fi

	if [ "$usbbridge_fail_cnt" -ge 6  ]; then
		log "usb bridge Fintek U1U F75115 AA88 test pass_cnt = $usbbridge_pass_cnt fail_cnt $usbbridge_fail_cnt"
		exit
	fi

	sleep 5
done
