#!/bin/bash -e

# Directory contains the target rootfs
TARGET_ROOTFS_DIR="binary"

if [ -e $TARGET_ROOTFS_DIR ]; then
        sudo rm -rf $TARGET_ROOTFS_DIR
fi

case "${ARCH:-$1}" in
	arm|arm32|armhf)
		ARCH=armhf
		;;
	*)
		ARCH=arm64
		;;
esac

echo -e "\033[36m Building for $ARCH \033[0m"

if [ ! $VERSION ]; then
	VERSION="debug"
fi

# Initialized to "eng", however this should be set in build.sh
if [ ! $VERSION_NUMBER ]; then
        VERSION_NUMBER="eng"
fi

echo -e "\033[36m Building for $VERSION \033[0m"

if [ ! -e  linaro-bullseye-$ARCH.tar.gz ]; then
	echo "\033[36m Run mk-base-debian.sh first \033[0m"
	exit -1
fi

echo -e "\033[36m Extract image \033[0m"
sudo tar -xpf linaro-bullseye-$ARCH.tar.gz

# packages folder
sudo mkdir -p $TARGET_ROOTFS_DIR/packages
sudo cp -rpf packages/$ARCH/* $TARGET_ROOTFS_DIR/packages

# overlay folder
sudo cp -rpf overlay/* $TARGET_ROOTFS_DIR/
if [ "$VERSION" == "sdflash" ]; then
	sudo mv $TARGET_ROOTFS_DIR/etc/init.d/sdflash-rockchip.sh $TARGET_ROOTFS_DIR/etc/init.d/rockchip.sh
else
	sudo rm -f $TARGET_ROOTFS_DIR/etc/init.d/sdflash-rockchip.sh
fi

# tinker-config
if [ "$RK_PROJECT_NAME" == "Tinker_Board_3" ]; then
    sudo mv $TARGET_ROOTFS_DIR/usr/bin/tinker-config-tb3 $TARGET_ROOTFS_DIR/usr/bin/tinker-config
    sudo rm $TARGET_ROOTFS_DIR/usr/bin/tinker-config-tb3n
else
    sudo mv $TARGET_ROOTFS_DIR/usr/bin/tinker-config-tb3n $TARGET_ROOTFS_DIR/usr/bin/tinker-config
    sudo rm $TARGET_ROOTFS_DIR/usr/bin/tinker-config-tb3
fi

# ASUS.GPIO & WiringPI
if [ "$RK_PROJECT_NAME" == "Tinker_Board_3" ]; then
	sudo mv $TARGET_ROOTFS_DIR/usr/local/share/ASUS_GPIO_3 $TARGET_ROOTFS_DIR/usr/local/share/ASUS_GPIO
	sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/ASUS_GPIO_3N
	sudo mv $TARGET_ROOTFS_DIR/usr/local/share/WiringPI_3 $TARGET_ROOTFS_DIR/usr/local/share/WiringPI
	sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/WiringPI_3N

else
	sudo mv $TARGET_ROOTFS_DIR/usr/local/share/ASUS_GPIO_3N $TARGET_ROOTFS_DIR/usr/local/share/ASUS_GPIO
	sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/ASUS_GPIO_3
	sudo mv $TARGET_ROOTFS_DIR/usr/local/share/WiringPI_3N $TARGET_ROOTFS_DIR/usr/local/share/WiringPI
	sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/WiringPI_3
fi

# overlay-firmware folder
sudo cp -rpf overlay-firmware/* $TARGET_ROOTFS_DIR/
sudo mkdir -p $TARGET_ROOTFS_DIR/tmp_firmware
sudo cp -rf overlay-firmware/usr/lib/firmware/* $TARGET_ROOTFS_DIR/tmp_firmware

# overlay-debug folder
# adb, video, camera  test file
if [ "$VERSION" == "debug" ]; then
	sudo cp -rpf overlay-debug/* $TARGET_ROOTFS_DIR/
        sudo rm -rf $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool*
	mkdir -p $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool
        sudo cp -arp overlay-debug/home/linaro/Desktop/Test_tool_$RK_PROJECT_NAME/* $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool/
fi

# overlay-debug and overlay-factory folder
# adb, video, camera  test file
if [ "$VERSION" == "factory" ]; then
        sudo cp -rpf overlay-debug/* $TARGET_ROOTFS_DIR/
        sudo rm -rf $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool*
        mkdir -p $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool
        sudo cp -arp overlay-debug/home/linaro/Desktop/Test_tool_$RK_PROJECT_NAME/* $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool/

        sudo cp -rf overlay-factory/* $TARGET_ROOTFS_DIR/
        sudo rm -rf $TARGET_ROOTFS_DIR/home/linaro/Desktop/factory_tools*
        mkdir -p $TARGET_ROOTFS_DIR/home/linaro/Desktop/factory_tools
        sudo cp -arp overlay-factory/home/linaro/Desktop/factory_tools_$RK_PROJECT_NAME/* $TARGET_ROOTFS_DIR/home/linaro/Desktop/factory_tools/
fi


# bt/wifi firmware
sudo mkdir -p $TARGET_ROOTFS_DIR/system/lib/modules/
sudo mkdir -p $TARGET_ROOTFS_DIR/vendor/etc

sudo find ../kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
    xargs -n1 -i sudo cp {} $TARGET_ROOTFS_DIR/system/lib/modules/

echo -e "\033[36m Change root.....................\033[0m"

sudo cp -f /etc/resolv.conf $TARGET_ROOTFS_DIR/etc/

#sudo find ../kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
#    xargs -n1 -i sudo cp {} $TARGET_ROOTFS_DIR/system/lib/modules/

# ASUS: Change to copy all the kernel modules built from build.sh.
sudo cp -rf lib_modules/lib/modules $TARGET_ROOTFS_DIR/lib/


sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

ID=$(stat --format %u $TARGET_ROOTFS_DIR)

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

# Fixup owners
if [ "$ID" -ne 0 ]; then
       find / -user $ID -exec chown -h 0:0 {} \;
fi
for u in \$(ls /home/); do
	chown -h -R \$u:\$u /home/\$u
done

echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 127.0.0.53" >> /etc/resolv.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.conf

echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib" >> /etc/apt/sources.list
echo "deb-src http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib" >> /etc/apt/sources.list

apt-get update
apt-get upgrade -y

export APT_INSTALL="apt-get install -fy --allow-downgrades"

# enter root username without password
# sed -i "s~\(^ExecStart=.*\)~# \1\nExecStart=-/bin/sh -c '/bin/bash -l </dev/%I >/dev/%I 2>\&1'~" /usr/lib/systemd/system/serial-getty@.service

#---------------tinker config-----------------
\${APT_INSTALL} plymouth plymouth-themes
plymouth-set-default-theme script

#---------------power management --------------
\${APT_INSTALL} pm-utils bsdmainutils
#cp /etc/Powermanager/triggerhappy.service  /lib/systemd/system/triggerhappy.service
#sed -i "s/#HandlePowerKey=.*/HandlePowerKey=ignore/" /etc/systemd/logind.conf

#---------------Virtual keyboard--------------
\${APT_INSTALL} onboard onboard-common

#---------------audio--------------
chmod 755 /usr/lib/pm-utils/sleep.d/02pulseaudio-resume
chmod 755 /etc/pulse/switch_sound_device.sh
chmod 755 /etc/pulse/jack_hotplug.sh
chmod 755 /usr/local/bin/switch_sound_device_boot.sh
ln -s /usr/lib/systemd/system/switch-sound-device-boot.service /etc/systemd/system/multi-user.target.wants/switch-sound-device-boot.service

#---------------ethernet---------------
chmod 755 /etc/network/ethernet_wol.sh
ln -s /usr/lib/systemd/system/ethernet-wol.service /etc/systemd/system/multi-user.target.wants/ethernet-wol.service

#---------------Rga--------------
\${APT_INSTALL} /packages/rga2/*.deb

echo -e "\033[36m Setup Video.................... \033[0m"
\${APT_INSTALL} gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-ugly gstreamer1.0-tools gstreamer1.0-alsa \
gstreamer1.0-plugins-base-apps

\${APT_INSTALL} /packages/mpp/*
\${APT_INSTALL} /packages/gst-rkmpp/*.deb
\${APT_INSTALL} /packages/gstreamer/*.deb
\${APT_INSTALL} /packages/gst-plugins-base1.0/*.deb
\${APT_INSTALL} /packages/gst-plugins-bad1.0/*.deb
\${APT_INSTALL} /packages/gst-plugins-good1.0/*.deb

#---------Camera---------
echo -e "\033[36m Install camera.................... \033[0m"
\${APT_INSTALL} cheese v4l-utils
\${APT_INSTALL} /packages/libv4l/*.deb
\${APT_INSTALL} /packages/cheese/*.deb
\${APT_INSTALL} /packages/rkaiq/camera_engine_rkaiq_rk3568_arm64.deb

#---------Network----------
apt-get install -y ethtool
apt-get install -y iperf3

#---------Xserver---------
echo -e "\033[36m Install Xserver.................... \033[0m"
\${APT_INSTALL} /packages/xserver/*.deb

apt-mark hold xserver-common xserver-xorg-core xserver-xorg-legacy

#---------Wayland/Weston---------
echo -e "\033[36m Install Wayland/Weston.................... \033[0m"
\${APT_INSTALL} /packages/weston/*.deb
\${APT_INSTALL} /packages/wayland/*.deb

#---------------Openbox--------------
echo -e "\033[36m Install openbox.................... \033[0m"
#\${APT_INSTALL} /packages/openbox/*.deb

#---------update chromium-----
\${APT_INSTALL} /packages/chromium/*.deb

#------------------libdrm------------
echo -e "\033[36m Install libdrm.................... \033[0m"
\${APT_INSTALL} /packages/libdrm/*.deb

#------------------libdrm-cursor------------
echo -e "\033[36m Install libdrm-cursor.................... \033[0m"
\${APT_INSTALL} /packages/libdrm-cursor/*.deb

#------------------blueman------------
echo -e "\033[36m Install blueman.................... \033[0m"
\${APT_INSTALL} blueman
echo exit 101 > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
\${APT_INSTALL} blueman
rm -f /usr/sbin/policy-rc.d

#------------------blueman------------
echo -e "\033[36m Install blueman.................... \033[0m"
\${APT_INSTALL} /packages/blueman/*.deb

# Change the background for ASUS Tinker Board
rm -rf /usr/share/images/desktop-base/default
ln -s /etc/ASUS/ASUS-2017-Tinkerboard-v1-wp-02-1920x1080.jpg /usr/share/images/desktop-base/default

#------------------rkwifibt------------
echo -e "\033[36m Install rkwifibt.................... \033[0m"
\${APT_INSTALL} /packages/rkwifibt/*.deb
ln -s /system/etc/firmware /vendor/etc/

#------------------modemmanager--------
echo -e "\033[36m Install modemmanager................ \033[0m"
\${APT_INSTALL} /packages/modemmanager/*.deb
sed -i 's/\/usr\/sbin\/ModemManager/\/usr\/sbin\/ModemManager --debug/' /lib/systemd/system/ModemManager.service

#------------------connectivity service-------------
echo -e "\033[36m Enable CM................ \033[0m"
systemctl enable mm_keepalive.service
systemctl enable asus_failover.service

if [ "$VERSION" == "debug" ] || [ "$VERSION" == "factory" ]; then
#------------------glmark2------------
echo -e "\033[36m Install glmark2.................... \033[0m"
\${APT_INSTALL} /packages/glmark2/*.deb
fi

#------------------mtd-utils------------
echo -e "\033[36m Install mtd-utils.................... \033[0m"
\${APT_INSTALL} mtd-utils

if [ -e "/usr/lib/aarch64-linux-gnu" ] ;
then
#------------------rknpu2------------
echo -e "\033[36m move rknpu2.................... \033[0m"
mv /packages/rknpu2/rknpu2.tar  /
fi

#------------------rktoolkit------------
echo -e "\033[36m Install rktoolkit.................... \033[0m"
\${APT_INSTALL} /packages/rktoolkit/*.deb

echo -e "\033[36m Install Chinese fonts.................... \033[0m"
# Uncomment zh_CN.UTF-8 for inclusion in generation
# sed -i 's/^# *\(zh_CN.UTF-8\)/\1/' /etc/locale.gen
# echo "LANG=zh_CN.UTF-8" >> /etc/default/locale

# Generate locale
# locale-gen

# Export env vars
# echo "export LC_ALL=zh_CN.UTF-8" >> ~/.bashrc
# echo "export LANG=zh_CN.UTF-8" >> ~/.bashrc
# echo "export LANGUAGE=zh_CN.UTF-8" >> ~/.bashrc

source ~/.bashrc

\${APT_INSTALL} ttf-wqy-zenhei fonts-aenigma
\${APT_INSTALL} xfonts-intl-chinese

#------------------pipewire------------
echo -e "\033[36m Install pipewire.................... \033[0m"
\${APT_INSTALL} pipewire pipewire-pulse pipewire-alsa libspa-0.2-bluetooth
\${APT_INSTALL} /packages/wireplumber/*.deb
find /usr/lib/systemd/ -name "wireplumber*.service" | xargs sed -i "/Environment/s/$/ DISPLAY=:0/"

# HACK debian11.3 to fix bug
#\${APT_INSTALL} fontconfig --reinstall

#\${APT_INSTALL} xfce4
#ln -sf /usr/bin/startxfce4 /etc/alternatives/x-session-manager

#---------------Install thunar-volman and auto mount storage start--------------
\${APT_INSTALL} thunar-volman gvfs gvfs-backends
cp /etc/ASUS/thunar-volman.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml

#---------------Install thunar-volman and auto mount storage end--------------

# HACK to disable the kernel logo on bootup
#sed -i "/exit 0/i \ echo 3 > /sys/class/graphics/fb0/blank" /etc/rc.local

cp /packages/libmali/libmali-*-x11*.deb /
#cp -rf /usr/lib/firmware/rockchip/ /

# reduce 500M size for rootfs
rm -rf /usr/lib/firmware
mkdir -p /usr/lib/firmware/
mv /tmp_firmware/* /usr/lib/firmware/
rm -rf /tmp_firmware

# mark package to hold
apt list --installed | grep -v oldstable | cut -d/ -f1 | xargs apt-mark hold

#---------------Custom Script--------------
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
rm /lib/systemd/system/wpa_supplicant@.service

#-------ASUS customization start-------

echo $VERSION_NUMBER > /etc/version

chmod a+x /etc/init.d/mountboot.sh
systemctl enable mountboot.service

if [ "$VERSION" == "factory" ]; then
	cp /etc/Ethernet/static-eth.service  /usr/lib/systemd/system/static-eth.service
	systemctl enable static-eth.service
fi

#-------ASUS customization end-------
# Install the gedit packages
apt-get install -y gedit

#-------Tinker board 3: python-dev for development tools------
apt-get install -y python-dev

# Install the bash-completion for apt-get tab auto search
apt-get install bash-completion

# Change default Terminal emulator to xfce4-terminal
\${APT_INSTALL} xfce4-terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 40
update-alternatives --auto x-terminal-emulator

#-------Tinker board 3: rknn-toolkit_lite2-------
if [ "$VERSION" == "debug" ] || [ "$VERSION" == "factory" ]; then
        chown -R linaro:linaro /home/linaro/Desktop
	# double click can to execuate the shell script file
	sed -i -e 's/x-shellscript=vim.desktop/x-shellscript=xfce4-terminal-emulator.desktop/g' /usr/share/applications/mimeinfo.cache
fi

# change owner and permission for install rknn toolkit lite2 script
chown -R linaro:linaro /usr/local/share/debian11_rknn_toolkit_lite2
chmod a+x /usr/local/share/debian11_rknn_toolkit_lite2/debian11_install_rknn_toolkit_lite2.sh
#-------Tinker board 3: rknn-toolkit_lite2-------

# Change systemd-suspend.service method to pm-suspend
cp /etc/Powermanager/systemd-suspend.service  /lib/systemd/system/systemd-suspend.service

#-------Tinker board 3: build-essential for development tools------
apt-get install -y build-essential

# -------Install for USB eject fail------
apt-get install -y eject

# -------Install for tinker-scheduler------
\${APT_INSTALL} gettext
\${APT_INSTALL} /packages/tinker-scheduler/*.deb

#---------------ncurses library--------------
\${APT_INSTALL} libncurses5-dev libncursesw5-dev
# For tinker-power-management build
cd /usr/local/share/tinker-power-management
gcc tinker-power-management.c -o tinker-power-management -lncursesw
mv tinker-power-management /usr/bin
cd /

#------- Wiring PI -------------------
cd /usr/local/share/WiringPI
./build Rockchip
cd /

#------- ASUS GPIO -------------------
apt-get install -y python3-pip python3-dev
pip3 install -y setuptools
cd /usr/local/share/ASUS_GPIO
python3 setup.py install
cd /

#------- factory library for opencv -------------------
if [ "$VERSION" == "factory" ]; then
        pip3 install opencv-python
        pip3 install opencv-contrib-python
fi


if [ "$VERSION" == "sdflash" ]; then
#---------------Set CLI Mode--------------
	rm -rf /etc/systemd/system/default.target
	ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

	echo "sudo tinker-upgrade" >> /home/linaro/.bashrc

#-------Install necessary kit for tinker-upgrade-------
	\${APT_INSTALL} pv
	\${APT_INSTALL} jq
	echo y | pip3 install pyppeteer
fi

#------remk-rootfs-bullseye.shmove unused packages------------
apt remove --purge -fy linux-firmware*

#---------------Clean--------------
if [ -e "/usr/lib/arm-linux-gnueabihf/dri" ] ;
then
        # Only preload libdrm-cursor for X
        sed -i "1aexport LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libdrm-cursor.so.1" /usr/bin/X
        cd /usr/lib/arm-linux-gnueabihf/dri/
        cp kms_swrast_dri.so swrast_dri.so rockchip_dri.so /
        rm /usr/lib/arm-linux-gnueabihf/dri/*.so
        mv /*.so /usr/lib/arm-linux-gnueabihf/dri/
elif [ -e "/usr/lib/aarch64-linux-gnu/dri" ];
then
        # Only preload libdrm-cursor for X
        sed -i "1aexport LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libdrm-cursor.so.1" /usr/bin/X
        cd /usr/lib/aarch64-linux-gnu/dri/
        cp kms_swrast_dri.so swrast_dri.so rockchip_dri.so /
        rm /usr/lib/aarch64-linux-gnu/dri/*.so
        mv /*.so /usr/lib/aarch64-linux-gnu/dri/
        rm /etc/profile.d/qt.sh
fi
cd -

if [ "$VERSION" == "release" ]; then
        sed -i "s|^autologin-user=.*|#autologin-user=linaro|" /etc/lightdm/lightdm.conf
        sed -i "s|^autologin-user-timeout=.*|#autologin-user-timeout=0|" /etc/lightdm/lightdm.conf
        passwd --expire linaro
	\${APT_INSTALL} light-locker
fi

#---------------Fix suspend resume can't enter login screen--------------
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/
rm -rf /packages/

EOF

sudo cp -f overlay/etc/resolv.conf $TARGET_ROOTFS_DIR/etc/

sudo umount $TARGET_ROOTFS_DIR/dev
