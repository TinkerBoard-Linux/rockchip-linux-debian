#!/bin/bash

eeprom_path=/sys/bus/i2c/devices/2-0050/eeprom
ifconfig=/usr/sbin/ifconfig
xxd=/usr/bin/xxd

function Ethernet_Check_MAC()
{
	LAN_PORT="$1"

	if [[ $LAN_PORT == "eth0" ]]; then
		echo "Ethernet (eth0) : check mac..."
		flag=0
	elif [[ $LAN_PORT == "eth1" ]]; then
		echo "Ethernet (eth1) : check mac..."
		flag=6
	else
		echo "Error : please add parameter eth0/eth1"
		return 1
	fi

	get_mac=$($ifconfig $LAN_PORT | grep ether | awk '{print $2}')
	current_mac=$(echo $get_mac | sed 's/://g')
	echo "Get Current MAC : " $current_mac
	eeprom_mac=$($xxd -s 0x$flag -l 6 -g 1 $eeprom_path | awk '{print $2$3$4$5$6$7}')
	echo "Get Eeprom MAC : $eeprom_mac"

	if echo "$eeprom_mac" | grep -qwi "$current_mac"; then
		return 0
	else
		return 1
	fi
}

Ethernet_Check_MAC "$@"
if [[ $? -eq 0 ]]; then
	echo "PASS"
else
	echo "FAIL"
fi
