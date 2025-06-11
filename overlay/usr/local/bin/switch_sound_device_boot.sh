#!/bin/sh
# Config audio output devices at boot time
hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
jack_tb3n_status=$(cat /sys/class/extcon/extcon3/cable.0/state)
jack_tb3_status=$(cat /sys/class/extcon/extcon3/cable.1/state)
max_timeout=6
elapsed=0
export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus


while ! pgrep -x pipewire > /dev/null || ! pgrep -x wireplumber > /dev/null; do
	if [ "$elapsed" -ge "$max_timeout" ]; then
		echo "PipeWire or WirePlumber did not start within $max_timeout seconds." > /dev/kmsg
		exit 1
	fi

	echo "Waiting for PipeWire and WirePlumber to start..." > /dev/kmsg
	sleep 1
	elapsed=$((elapsed + 1))
done

if [ $hdmi_status = "connected" ];
then
	if [ "$jack_tb3n_status" = 1 ] || [ "$jack_tb3_status" = 1 ];
	then
		echo "Audio jack is connected, set default sound card to RK809" > /dev/kmsg
		/bin/bash  /etc/wireplumber/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
	else
		echo "HDMI is connected, set default sound card to HDMI" > /dev/kmsg
		/bin/bash /etc/wireplumber/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
	fi
else
	echo "HDMI is disconnected, set default sound card to RK809" > /dev/kmsg
	/bin/bash  /etc/wireplumber/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
fi
