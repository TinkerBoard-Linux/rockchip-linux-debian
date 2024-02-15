#!/bin/bash
TAG=JACK_MAX32558VER
logfile=$1
SCRIPTPATH=$2
pass_cnt=0
fail_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	max32558_ver=""
	max32558_ver=`python3 $SCRIPTPATH/test/max-test-prod/send_scp/src/listen_timeout.py -s /dev/ttyS4 | grep build_ver | tail -n1 | awk '{split($0,a,":"); print a[2]}'`
	if [ -n "$max32558_ver" ]; then
		echo "MAX32558 is working properly. Current version is: $max32558_ver"
		log "MAX32558 is working properly. Current version is: $max32558_ver"
		((pass_cnt+=1))
		log "pass_cnt=$pass_cnt"
		fail_cnt=0

	else
		echo "MAX32558 device not found."
		log  "MAX32558 device not found."
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi	
	if [ "$fail_cnt" -ge 6  ]; then
		log "MAX32558 version pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
	sleep 2
done
