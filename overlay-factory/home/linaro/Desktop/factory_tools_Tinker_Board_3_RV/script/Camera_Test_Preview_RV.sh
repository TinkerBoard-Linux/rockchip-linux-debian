#!/bin/bash
#sudo apt-get install zbar-tools
#sudo apt-get install v4l-utils

i=0
ERROR=0
ResultFile="/tmp/Camera_Test_QRcode_Result.txt"
PicPath="/tmp/Capture.jpg"
QRCodeResult="/tmp/QRCode_Result.txt"
CSI0="/dev/video0"

echo -e "Start Camera Test QR code!" | tee -a $ResultFile
if [ -f $ResultFile ]; then
	echo "$ResultFile EXIST, Revmove $ResultFile!"
	rm -rf $ResultFile
fi

if [ -f $PicPath ]; then
	echo "$PicPath EXIST, Revmove $PicPath!"
	rm -rf $PicPath
fi

if [ -f $QRCodeResult ]; then
	echo "$QRCodeResult EXIST, Revmove $QRCodeResult!"
	rm -rf $QRCodeResult
fi

cat /sys/bus/i2c/drivers/imx219/1-0010/name |grep "imx219"
if [ "$?" == "0" ]; then
	echo -e "Start Capture!" | tee -a $ResultFile
	gst-launch-1.0 v4l2src device=/dev/video0 device=$CSI0 num-buffers=200 ! video/x-raw,format=NV12,width=1280,height=960 ! videoconvert ! autovideosink
	gst-launch-1.0 v4l2src device=/dev/video0 device=$CSI0 num-buffers=30 ! video/x-raw,format=NV12,width=1280,height=960 ! jpegenc ! multifilesink location=$PicPath
	echo -e "Read QR code" | tee -a $ResultFile
	zbarimg $PicPath > $QRCodeResult
	cat $QRCodeResult |grep "asuscamera"
	if [ "$?" == "0" ]; then
		echo -e "PASS" | tee -a $ResultFile
	else
		# Fail: picture not found
		echo "FAILValue=3" | tee -a $ResultFile
	fi
else
	# Fail: camera not fount
	echo "FAILValue=2"  | tee -a $ResultFile
fi
