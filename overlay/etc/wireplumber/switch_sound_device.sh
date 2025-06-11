#!/bin/bash


TARGET_SINK_NAME="$1"

if [ -z "$TARGET_SINK_NAME" ]; then
  echo "Usage: $0 <sink-sink-name>"
  exit 1
fi

echo "Config default sound output device: $TARGET_SINK_NAME"

# Find pw-cli sink Node ID
PW_NODE_ID=$(pw-cli ls Node | awk -v target="$TARGET_SINK_NAME" '
  BEGIN { id = "" }
  $1 == "id" && $2 ~ /^[0-9]+,/ { current_id = $2; gsub(",", "", current_id) }
  $1 == "node.name" && $3 == "\""target"\"" {
    print current_id;
    exit;
  }
  ')

if [ -z "$PW_NODE_ID" ]; then
  echo "ERROR: Cannot find PipeWire Node ID for $TARGET_SINK_NAME, try wpctl for decisions"
fi

# If you're playing sounds, switch running stream to your specified output.
#echo "Switch running active stream(s) to sink: $TARGET_SINK_NAME (node id: $PW_NODE_ID)"

# Find media.class = Stream/Output Node（Current running stream）
STREAM_IDS=$(pw-cli ls Node | awk '
  $1 == "id" && $2 ~ /^[0-9]+,/ {
    id = $2; gsub(",", "", id);
  }
  $1 == "media.class" && $3 ~ /"Stream\/Output/ {
    print id;
  }
  ')

for STREAM_ID in $STREAM_IDS; do
  #echo "Move stream ID $STREAM_ID to sink node ID $PW_NODE_ID"
  #pw-cli set-param "$STREAM_ID" Props "{ target.node = $PW_NODE_ID }"
  wpctl set-default "$PW_NODE_ID"
done

# title mapping table
declare -A SINK_TITLES
SINK_TITLES["alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"]="Built-in Audio Headphones + Speaker"
SINK_TITLES["alsa_output.platform-hdmi-sound.stereo-fallback"]="HDMI"

TITLE="${SINK_TITLES[$TARGET_SINK_NAME]}"
if [ -z "$TITLE" ]; then
  echo "ERROR：unknow sink name：$TARGET_SINK_NAME"
  exit 1
fi

DEFAULT_SINK_ID=$(wpctl status | awk '/Sinks:/ {show=1; next} /Sink endpoints:/ {show=0} show' | grep "$TITLE" | sed -n 's/^[^0-9]*\([0-9]\+\)\..*/\1/p')

if [ -z "$DEFAULT_SINK_ID" ]; then
  echo "ERROR: Cannot find sink ID for $TARGET_SINK_NAME"
  exit 1
fi

#echo "Default sink ID: $DEFAULT_SINK_ID"
wpctl set-default "$DEFAULT_SINK_ID"

#echo "Done."
