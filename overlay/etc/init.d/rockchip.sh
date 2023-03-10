#!/bin/bash -e
### BEGIN INIT INFO
# Provides:          rockchip
# Required-Start:
# Required-Stop:
# Default-Start:
# Default-Stop:
# Short-Description:
# Description:       Setup rockchip platform environment
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

install_packages() {
    case $1 in
        rk3288)
		MALI=midgard-t76x-r18p0-r0p0
		ISP=rkisp
		# 3288w
		cat /sys/devices/platform/*gpu/gpuinfo | grep -q r1p0 && \
		MALI=midgard-t76x-r18p0-r1p0
		sed -i "s/always/none/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		[ -e /usr/lib/arm-linux-gnueabihf/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
        rk3399|rk3399pro)
		MALI=midgard-t86x-r18p0
		ISP=rkisp
		sed -i "s/always/none/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		[ -e /usr/lib/aarch64-linux-gnu/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
        rk3328)
		MALI=utgard-450
		ISP=rkisp
		sed -i "s/always/none/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		[ -e /usr/lib/aarch64-linux-gnu/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
        rk3326|px30)
		MALI=bifrost-g31-g2p0
		ISP=rkisp
		sed -i "s/always/none/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		[ -e /usr/lib/aarch64-linux-gnu/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
        rk3128|rk3036)
		MALI=utgard-400
		ISP=rkisp
		sed -i "s/always/none/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		[ -e /usr/lib/arm-linux-gnueabihf/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
        rk3568|rk3566)
		MALI=bifrost-g52-g2p0
		ISP=rkaiq_rk3568
		sed -i "s/always/none/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		sed -i "s/glamor/exa/g" /etc/X11/xorg.conf.d/20-modesetting.conf
		[ -e /usr/lib/aarch64-linux-gnu/ ] && tar xvf /rknpu2-rk3568-*.tar -C /
		[ -e /usr/lib/aarch64-linux-gnu/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
        rk3588|rk3588s)
		ISP=rkaiq_rk3588
		MALI=valhall-g610-g6p0
		[ -e /usr/lib/aarch64-linux-gnu/ ] && tar xvf /rknpu2-rk3588-*.tar -C /
		[ -e /usr/lib/aarch64-linux-gnu/ ] && apt install -fy --allow-downgrades /camera_engine_$ISP*.deb
		;;
    esac

    apt install -fy --allow-downgrades /libmali-*$MALI*-x11*.deb
}


function update_npu_fw() {
    /usr/bin/npu-image.sh
    sleep 1
    /usr/bin/npu_transfer_proxy&
}

COMPATIBLE=$(cat /proc/device-tree/compatible)
if [[ $COMPATIBLE =~ "rk3288" ]];
then
    CHIPNAME="rk3288"
elif [[ $COMPATIBLE =~ "rk3328" ]]; then
    CHIPNAME="rk3328"
elif [[ $COMPATIBLE =~ "rk3399" && $COMPATIBLE =~ "rk3399pro" ]]; then
    CHIPNAME="rk3399pro"
    update_npu_fw
elif [[ $COMPATIBLE =~ "rk3399" ]]; then
    CHIPNAME="rk3399"
elif [[ $COMPATIBLE =~ "rk3326" ]]; then
    CHIPNAME="rk3326"
elif [[ $COMPATIBLE =~ "px30" ]]; then
    CHIPNAME="px30"
elif [[ $COMPATIBLE =~ "rk3128" ]]; then
    CHIPNAME="rk3128"
elif [[ $COMPATIBLE =~ "rk3566" ]]; then
    CHIPNAME="rk3566"
elif [[ $COMPATIBLE =~ "rk3568" ]]; then
    CHIPNAME="rk3568"
elif [[ $COMPATIBLE =~ "rk3588" ]]; then
    CHIPNAME="rk3588"

else
    CHIPNAME="rk3036"
fi
COMPATIBLE=${COMPATIBLE#rockchip,}
BOARDNAME=${COMPATIBLE%%rockchip,*}

#create HDMI/DP config for xrandr to save hotplug status
HDMI_HOTPLUG_CONFIG="/boot/display/hdmi/hdmi_plug_flag.cfg"
DP_HOTPLUG_CONFIG="/boot/display/dp/dp_plug_flag.cfg"
HDMI_XRANDR_CONFIG="/boot/display/hdmi/xrandr.cfg"
DP_XRANDR_CONFIG="/boot/display/dp/xrandr.cfg"

# Enable WOL function
/etc/network/ethernet_wol.sh

# first boot configure
if [ ! -e "/usr/local/first_boot_flag" ] ;
then
    echo "It's the first time booting."
    echo "The rootfs will be configured."

    # Force rootfs synced
    mount -o remount,sync /

    # Resize rootfs
    resize-helper

    install_packages ${CHIPNAME}

    setcap CAP_SYS_ADMIN+ep /usr/bin/gst-launch-1.0

    if [ -e "/dev/rfkill" ] ;
    then
       rm /dev/rfkill
    fi

    rm -rf /*.deb
    rm -rf /*.tar

    # The base target does not come with lightdm/rkaiq_3A
if [ -e /etc/gdm3/daemon.conf ]; then
    systemctl restart gdm3.service || true
elif [ -e /etc/lightdm/lightdm.conf ]; then
    systemctl restart lightdm.service || true
fi
    systemctl restart rkaiq_3A.service || true

    touch /usr/local/first_boot_flag

    mkdir /boot/display
    mkdir /boot/display/hdmi
    mkdir /boot/display/dp
    touch $HDMI_HOTPLUG_CONFIG
    touch $DP_HOTPLUG_CONFIG
    touch $HDMI_XRANDR_CONFIG
    touch $DP_XRANDR_CONFIG
fi

# enable rkwifbt service
#service rkwifibt start

# enable async service
#service async start

# enable adbd service
#service adbd start

# set act-led trigger function
cmdline=$(cat /proc/cmdline)
storage=`echo $cmdline|awk '{print match($0,"storagemedia=emmc")}'`;

if [ $storage -gt 0 ]; then
    #emmc
    echo mmc0 > /sys/class/leds/act-led/trigger
else
    #sdcard
    echo mmc1 > /sys/class/leds/act-led/trigger
fi

# set cpu governor and frequence
CPU_GOVERNOR=$(cat /boot/config.txt | grep 'cpu_governor' | cut -d '=' -f2)
A53_MINFREQ=$(cat /boot/config.txt | grep 'a53_minfreq' | cut -d '=' -f2)
A53_MAXFREQ=$(cat /boot/config.txt | grep 'a53_maxfreq' | cut -d '=' -f2)
A72_MINFREQ=$(cat /boot/config.txt | grep 'a72_minfreq' | cut -d '=' -f2)
A72_MAXFREQ=$(cat /boot/config.txt | grep 'a72_maxfreq' | cut -d '=' -f2)

GPU_GOVERNOR=$(cat /boot/config.txt | grep 'gpu_governor' | cut -d '=' -f2)
T86X_MINFREQ=$(cat /boot/config.txt | grep 't86x_minfreq' | cut -d '=' -f2)
T86X_MAXFREQ=$(cat /boot/config.txt | grep 't86x_maxfreq' | cut -d '=' -f2)

if [ $CPU_GOVERNOR ] && [ $A53_MINFREQ -gt 0 ] && [ $A53_MAXFREQ -gt 0 ] && [ $A72_MINFREQ -gt 0 ] && [ $A72_MAXFREQ -gt 0 ]; then
    sudo su -c "echo $CPU_GOVERNOR > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor"
    sudo su -c "echo $CPU_GOVERNOR > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor"
    sudo su -c "echo $A53_MINFREQ > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq"
    sudo su -c "echo $A53_MAXFREQ > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq"
    sudo su -c "echo $A72_MINFREQ > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq"
    sudo su -c "echo $A72_MAXFREQ > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq"
fi

if [ $GPU_GOVERNOR ] && [ $T86X_MINFREQ -gt 0 ] && [ $T86X_MAXFREQ -gt 0 ]; then
    sudo su -c "echo $GPU_GOVERNOR > /sys/class/devfreq/ff9a0000.gpu/governor"
    sudo su -c "echo $T86X_MINFREQ > /sys/class/devfreq/ff9a0000.gpu/min_freq"
    sudo su -c "echo $T86X_MAXFREQ > /sys/class/devfreq/ff9a0000.gpu/max_freq"
fi

# support power management
if [ -e "/usr/sbin/pm-suspend" -a -e /etc/Powermanager ] ;
then
    #mv /etc/Powermanager/power-key.sh /usr/bin/
    #mv /etc/Powermanager/power-key.conf /etc/triggerhappy/triggers.d/
    if [[ "$CHIPNAME" == "rk3399pro" ]];
    then
        mv /etc/Powermanager/01npu /usr/lib/pm-utils/sleep.d/
        mv /etc/Powermanager/02npu /lib/systemd/system-sleep/
    fi
    mv /etc/Powermanager/03wifibt /usr/lib/pm-utils/sleep.d/
    mv /etc/Powermanager/04wifibt /lib/systemd/system-sleep/
    #mv /etc/Powermanager/triggerhappy /etc/init.d/triggerhappy

    rm /etc/Powermanager -rf
    #service triggerhappy restart
fi

# Create dummy video node for chromium V4L2 VDA/VEA with rkmpp plugin
echo dec > /dev/video-dec0
echo enc > /dev/video-enc0
chmod 660 /dev/video-*
chown root.video /dev/video-*

# The chromium using fixed pathes for libv4l2.so
ln -rsf /usr/lib/*/libv4l2.so /usr/lib/
[ -e /usr/lib/aarch64-linux-gnu/ ] && ln -Tsf lib /usr/lib64

# sync system time
hwclock --systohc

# read mac-address from efuse
# if [ "$BOARDNAME" == "rk3288-miniarm" ]; then
#     MAC=`xxd -s 16 -l 6 -g 1 /sys/bus/nvmem/devices/rockchip-efuse0/nvmem | awk '{print $2$3$4$5$6$7 }'`
#     ifconfig eth0 hw ether $MAC
# fi
