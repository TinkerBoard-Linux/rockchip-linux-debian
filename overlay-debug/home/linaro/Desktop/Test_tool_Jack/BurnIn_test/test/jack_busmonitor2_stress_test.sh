#!/bin/bash
TAG=JACK_BUSMONITOR
logfile=$1
hwmon_path=$2
busmonitor_num=$3
pass_cnt=0
fail_cnt=0


log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	test_path=`cat  $hwmon_path/curr1_input`
	if [ -n "$test_path" ]; then
		for i in $( seq 1 $busmonitor_num )
		do
			current=`cat  $hwmon_path/curr${i}_input`
			voltage=`cat  $hwmon_path/in${i}_input`
			label=`cat  $hwmon_path/in${i}_label`
			busmonitor1[${i}]="Name="$label", voltage="$voltage" mv, current="$current" mA"
		done
		echo "BUS_MONITOR:"
		log "BUS_MONITOR:"
		for i in "${busmonitor1[@]}"
		do
			echo "\t$i"
			log "\t$i"
		done

		((pass_cnt+=1))
		log "pass_cnt=$pass_cnt"
		fail_cnt=0

	else
		echo "BUS_MONITOR device not found."
		log  "BUS_MONITOR device not found."
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi	
	if [ "$fail_cnt" -ge 6  ]; then
		log "TBUS_MONITOR pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
	sleep 2
done
