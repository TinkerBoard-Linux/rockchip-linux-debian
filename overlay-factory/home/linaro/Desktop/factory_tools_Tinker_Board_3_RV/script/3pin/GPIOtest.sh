#!/bin/bash

# Define GPIO pin arrays (corrected numbering based on your comments)
gpio_a=(16 17 20)
gpio_b=(17 20 16)
gpio_c=(20 16 17)

# Initialize test result
result="PASS"

# Function to reset GPIO pin
function gpio_reset() {
  local gpio_pin="$1"
  local path="/sys/class/gpio/"

  if [ -d "$path" ]; then
    echo "$gpio_pin" > "$path/unexport"
  fi
  echo "$gpio_pin" > "$path/export"
}

# Function to perform self-test on a pair of GPIO pins
function gpio_selftest() {
  local index="$1"
  local output_pin="$2"
  local input_pin="$3"
  local input_pin_2="$4"

  # Set pin directions and initial output value
  echo "in" > "/sys/class/gpio/gpio${input_pin}/direction"
  echo "in" > "/sys/class/gpio/gpio${input_pin_2}/direction"
  echo "out" > "/sys/class/gpio/gpio${output_pin}/direction"
  echo "0" > "/sys/class/gpio/gpio${output_pin}/value"

  # Read pin values for low and high output states
  local FromStatusL=$(cat "/sys/class/gpio/gpio${output_pin}/value")
  local ToStatusL=$(cat "/sys/class/gpio/gpio${input_pin}/value")
  local ToStatusL_2=$(cat "/sys/class/gpio/gpio${input_pin_2}/value")

  echo "out" > "/sys/class/gpio/gpio${output_pin}/direction"
  echo "1" > "/sys/class/gpio/gpio${output_pin}/value"

  local FromStatusH=$(cat "/sys/class/gpio/gpio${output_pin}/value")
  local ToStatusH=$(cat "/sys/class/gpio/gpio${input_pin}/value")
  local ToStatusH_2=$(cat "/sys/class/gpio/gpio${input_pin_2}/value")

  # Print status information and check for successful test
#  echo "IN=PIN#${input_pin}, OUT=PIN#${output_pin}"
  #echo "FromStatusL=${FromStatusL} ToStatusL=${ToStatusL} FromStatusH=${FromStatusH} ToStatusH=${ToStatusH}"
  if [[ $FromStatusL -eq 0 && $ToStatusL -eq 0 && $ToStatusL_2 -eq 0 && $FromStatusH -eq 1 && $ToStatusH -eq 1 && $ToStatusH_2 -eq 1 ]]; then
#    echo "PASS"
    result="PASS"
  else
    result="FAIL"
  fi
}

# Loop through each pair of pins and perform self-test in both directions
for ((i = 0; i < ${#gpio_a[@]}; i++)); do
  gpio_reset "${gpio_a[$i]}"
  gpio_reset "${gpio_b[$i]}"
  gpio_reset "${gpio_c[$i]}"

  gpio_selftest "$i" "${gpio_a[$i]}" "${gpio_b[$i]}" "${gpio_c[$i]}"
  if [ "$result" == "FAIL" ]; then
    echo "FAIL, ${gpio_a[$i]} to ${gpio_b[$i]} and ${gpio_c[$i]}"
    break
  fi

  gpio_selftest "$i" "${gpio_b[$i]}" "${gpio_a[$i]}" "${gpio_c[$i]}"
  if [ "$result" == "FAIL" ]; then
    echo "FAIL, ${gpio_b[$i]} to ${gpio_a[$i]} and ${gpio_c[$i]}"
    break
  fi
  gpio_selftest "$i" "${gpio_c[$i]}" "${gpio_a[$i]}" "${gpio_b[$i]}"
  if [ "$result" == "FAIL" ]; then
    echo "FAIL, ${gpio_c[$i]} to ${gpio_a[$i]} and ${gpio_b[$i]}"
    break
  fi
done

# Print final test result

if [ "$result" == "PASS" ]; then
  echo "$result"
fi

