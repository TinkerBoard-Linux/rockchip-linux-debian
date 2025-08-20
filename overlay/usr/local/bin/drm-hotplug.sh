#!/bin/sh -x

# Try to figure out XAUTHORITY and DISPLAY
for pid in $(pgrep X 2>/dev/null || ls /proc|grep -ow "[0-9]*"|sort -rn); do
    PROC_DIR=/proc/$pid

    # Filter out non-X processes
    readlink $PROC_DIR/exe|grep -qwE "X$|Xorg$" || continue

    # Parse auth file and display from cmd args
    export XAUTHORITY=$(cat $PROC_DIR/cmdline|tr '\0' '\n'| \
        grep -w "\-auth" -A 1|tail -1)
    export DISPLAY=$(cat $PROC_DIR/cmdline|tr '\0' '\n'| \
        grep -w "^:.*" || echo ":0")

    echo Found auth: $XAUTHORITY for dpy: $DISPLAY
    break
done

export DISPLAY=${DISPLAY:-:0}

# Find an authorized user
unset USER
for user in root $(users);do
    sudo -u $user xdpyinfo &>/dev/null && \
        { USER=$user; break; }
done
[ $USER ] || exit 0

HDMI="HDMI-1"
DP="DP-1"

HDMI_SYS="/sys/class/drm/card0-HDMI-A-1"
DP_SYS="/sys/class/drm/card0-DP-1"

HDMI_XRANDR_CONFIG="/boot/display/hdmi/xrandr.cfg"
DP_XRANDR_CONFIG="/boot/display/dp/xrandr.cfg"
HDMI_XRANDR_CONFIG_UNPLUG="/boot/display/hdmi/xrandr_unplug.cfg"
DP_XRANDR_CONFIG_UNPLUG="/boot/display/dp/xrandr_unplug.cfg"

HDMI_HOTPLUG_CONFIG="/boot/display/hdmi/hdmi_plug_flag.cfg"
DP_HOTPLUG_CONFIG="/boot/display/dp/dp_plug_flag.cfg"


HDMI_MODES_NODE="$HDMI_SYS/modes"
DP_MODES_NODE="$DP_SYS/modes"

HDMI_MODE_NODE="$HDMI_SYS/mode"
DP_MODE_NODE="$DP_SYS/mode"

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)
jack_tb3n_status=$(cat /sys/class/extcon/extcon3/cable.0/state)
jack_tb3_status=$(cat /sys/class/extcon/extcon3/cable.1/state)


#Save resolution if the external display is disconnected
#HDMI
if [ $hdmi_status = "disconnected" ]; then
	if [ -f $HDMI_HOTPLUG_CONFIG ]; then
		if [ "$(cat $HDMI_HOTPLUG_CONFIG)" != "Plug_Out" ]; then
			if [ -f $HDMI_XRANDR_CONFIG ]; then
				if [ "$(cat $HDMI_XRANDR_CONFIG)" != "" ]; then
					su $user -c "echo $(cat $HDMI_XRANDR_CONFIG)" > $HDMI_XRANDR_CONFIG_UNPLUG
				fi
			fi
		fi
	fi
	sudo -u $user xrandr --output $HDMI --off
	su $user -c "echo Plug_Out" > $HDMI_HOTPLUG_CONFIG
fi

#DP
if [ $dp_status = "disconnected" ]; then
	if [ -f $DP_HOTPLUG_CONFIG ]; then
		if [ "$(cat $DP_HOTPLUG_CONFIG)" != "Plug_Out" ]; then
			if [ -f $DP_XRANDR_CONFIG ]; then
				if [ "$(cat $DP_XRANDR_CONFIG)" != "" ]; then
					su $user -c "echo $(cat $DP_XRANDR_CONFIG)" > $DP_XRANDR_CONFIG_UNPLUG
				fi
			fi
		fi
	fi
	sudo -u $user xrandr --output $DP --off
	su $user -c "echo Plug_Out" > $DP_HOTPLUG_CONFIG
fi

#Restore external display preview resolution
#HDMI
sudo -u $user xrandr
if [ $hdmi_status = "connected" ]; then
	if [ -f $HDMI_HOTPLUG_CONFIG ]; then
		if [ "$(cat $HDMI_HOTPLUG_CONFIG)" = "Plug_Out" ]; then
			if [ -f $HDMI_XRANDR_CONFIG ]; then
				if grep -q $(cat $HDMI_XRANDR_CONFIG) $HDMI_MODES_NODE; then
					sudo -u $user xrandr --output $HDMI --mode $(cat $HDMI_XRANDR_CONFIG_UNPLUG)
				else
					sudo -u $user xrandr --output $HDMI --auto
				fi
			else
				sudo -u $user xrandr --output $HDMI --auto
			fi
		#else
		#	if [ "$(cat $HDMI_MODE_NODE)" = "" ]; then
		#		sudo -u $user xrandr --output $HDMI --auto
		#	fi
		fi
	fi
	su $user -c "echo Plug_In" > $HDMI_HOTPLUG_CONFIG
fi

#DP
if [ $dp_status = "connected" ]; then
	if [ -f $DP_HOTPLUG_CONFIG ]; then
		if [ "$(cat $DP_HOTPLUG_CONFIG)" = "Plug_Out" ]; then
			if [ -f $DP_XRANDR_CONFIG ]; then
				if grep -q $(cat $DP_XRANDR_CONFIG) $DP_MODES_NODE; then
					sudo -u $user xrandr --output $DP --mode $(cat $DP_XRANDR_CONFIG_UNPLUG)
				else
					sudo -u $user xrandr --output $DP --auto
				fi
			else
				sudo -u $user xrandr --output $DP --auto
			fi
		#else
		#	if [ "$(cat $DP_MODE_NODE)" = "" ]; then
		#		sudo -u $user xrandr --output $DP --auto
		#	fi
		fi
	fi
	su $user -c "echo Plug_In" > $DP_HOTPLUG_CONFIG
fi

# Config audio output devices when HDMI hot-plug
export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
if [ $hdmi_status = "connected" ];
then
	if [ $jack_tb3n_status = 1 ] || [ $jack_tb3_status = 1 ];
	then
		echo "Plug-in HDMI, but audio jack is connected, set default sound card to RK809"  > /dev/kmsg
		/etc/wireplumber/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
	else
		echo "Plug-in HDMI, set default sound card to HDMI"  > /dev/kmsg
		/etc/wireplumber/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
	fi
else
	hdmi_enabled=$(cat /sys/class/drm/card0-HDMI-A-1/enabled)
	if [ $hdmi_enabled = "enabled" ];
	then
		echo "Plug-in HDMI, but HDMI status is '$hdmi_status', check hdmi enabled value is '$hdmi_enabled', set default sound card to HDMI"  > /dev/kmsg
		/etc/wireplumber/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
	else
		echo "Plug-out HDMI, check hdmi enabled value is '$hdmi_enabled', set default sound card to RK809"  > /dev/kmsg
		/etc/wireplumber/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
	fi
fi

exit 0
