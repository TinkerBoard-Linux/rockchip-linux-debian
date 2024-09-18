#!/bin/bash
USB3_PORT_1_SPEED="/sys/devices/platform/usbhost/fd000000.dwc3/xhci-hcd.*.auto/usb*/*-1/speed"

USB_HUB_SPEED="/sys/devices/platform/fd800000.usb/usb*/*-1/speed"
USB2_PORT_1_SPEED="/sys/devices/platform/fd800000.usb/usb*/*-1/*-1.1/speed"
USB2_PORT_2_SPEED="/sys/devices/platform/fd800000.usb/usb*/*-1/*-1.2/speed"
USB2_PORT_3_SPEED="/sys/devices/platform/fd800000.usb/usb*/*-1/*-1.3/speed"
var="PASS"

grep 5000 $USB3_PORT_1_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    var="FAIL, usb3 port speed is abnormal"
fi

ls $USB_HUB_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb2 hub not found"
    else
        var="FAIL, usb2 hub not found"
    fi
    echo $var
    exit
fi

grep 480 $USB_HUB_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb2 hub speed is abnormal"
    else
        var="FAIL, usb2 hub speed is abnormal"
    fi
    echo $var
    exit
fi

grep 480 $USB2_PORT_1_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb2 port1 speed is abnormal"
    else
        var="FAIL, usb2 port1 speed is abnormal"
    fi
fi

grep 480 $USB2_PORT_2_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb2 port2 speed is abnormal"
    else
        var="FAIL, usb2 port2 speed is abnormal"
    fi
fi

grep 480 $USB2_PORT_3_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb2 port3 speed is abnormal"
    else
        var="FAIL, usb2 port3 speed is abnormal"
    fi
fi

echo $var
