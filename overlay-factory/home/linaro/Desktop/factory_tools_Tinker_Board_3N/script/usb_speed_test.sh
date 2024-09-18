#!/bin/bash

USB_HUB_SPEED="/sys/devices/platform/usbhost/fd000000.dwc3/xhci-hcd.*.auto/usb*/*-1/speed"
USB3_PORT_1_SPEED="/sys/devices/platform/usbhost/fd000000.dwc3/xhci-hcd.*.auto/usb*/*-1/*-1.3/speed"
USB3_PORT_2_SPEED="/sys/devices/platform/usbhost/fd000000.dwc3/xhci-hcd.*.auto/usb*/*-1/*-1.2/speed"
var="PASS"

grep 5000 $USB3_PORT_1_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    var="FAIL, usb3 port1 speed is abnormal"
fi

ls $USB_HUB_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb hub not found"
    else
        var="FAIL, usb hub not found"
    fi
    echo $var
    exit
fi

grep 5000 $USB_HUB_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb3 hub speed is abnormal"
    else
        var="FAIL, usb3 hub speed is abnormal"
    fi
    echo $var
    exit
fi

grep 5000 $USB3_PORT_1_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb3 port1 speed is abnormal"
    else
        var="FAIL, usb3 port1 speed is abnormal"
    fi
fi

grep 5000 $USB3_PORT_2_SPEED > /dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ "$var" != "PASS" ]; then
        var="$var, usb3 port2 speed is abnormal"
    else
        var="FAIL, usb3 port2 speed is abnormal"
    fi
fi

echo $var
