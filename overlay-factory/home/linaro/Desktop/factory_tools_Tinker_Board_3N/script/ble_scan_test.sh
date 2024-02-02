# /bin/bash

scan_time=$1
mac_address=$2

if [ -z "$scan_time" ] && [ -z "$mac_address" ]; then
	echo Invalid parameter, please execute \""bash ble_scan_test.sh <scan time> <mac address>\""
	exit
fi

BT_STATUS=$(hciconfig hci0 | grep -i 'running' 2>&1 >/dev/null; echo $?)
if [ $BT_STATUS = "1" ]; then
	hciconfig hci0 up
	bt_ret=$(hciconfig hci0 | grep -i 'running' 2>&1 >/dev/null; echo $?)
	if [ $bt_ret = "1" ]; then
		echo Error, fail to turn BT on.
		exit
	fi
fi

ble_ret=`scanner $1 | grep -ie $mac_address`
if [[ $ble_ret == *$mac_address ]]; then
	echo PASS
else
	echo FAIL
fi
