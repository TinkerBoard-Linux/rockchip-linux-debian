#!/bin/bash -e
### BEGIN INIT INFO
# Provides: wifi_keepalive
# Required-Start:
# Required-Stop:
# Default-Start:
# Default-Stop:
# Short-Description:
# Description: Wi-Fi keepalive service
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

log() {
	echo "${1}"
	logger -t ${TAG} ${1}
}

wifi_keepalive()
{
	log "wifi_keepalive start"
	IF_DEV="wlp1s0"

	while $start_service; do
		state=$(nmcli device status | grep "${IF_DEV} " | head -n1 | awk '{print $3}')
		if [[ "$state" == "disconnected" ]]; then
			echo "INFO: Caught NM sitting idle. Forcing it to try to reconnect again!";
			nmcli device connect "${IF_DEV}"
		fi
		sleep 10;
	done
}

case "$1" in
	start)
		start_service=true
		wifi_keepalive
		;;
	stop)
		start_service=false
		;;
	restart|reload)
		;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?
