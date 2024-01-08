#!/bin/bash
TAG=USBDAC_JACK
logfile=$1
usbdac_pass_cnt=0
usbdac_fail_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	lsusb|grep "08bb:2912"
	if [ "$?" == "0" ]; then
		log "Found PCM2912A Audio Codec."
		((usbdac_pass_cnt+=1))
		usbdac_fail_cnt=0
		log "usbdac_pass_cnt=$usbdac_pass_cnt"
	else
		log "Can not found PCM2912A Audio Codec."
		((usbdac_fail_cnt+=1))
		log "usbdac_fail_cnt=$usbdac_fail_cnt"
	fi

	if [ "$usbdac_fail_cnt" -ge 6  ]; then
		log "PCM2912A Audio Codec test pass_cnt = $usbdac_pass_cnt fail_cnt $usbdac_fail_cnt"
		exit
	fi

	sleep 5
done
