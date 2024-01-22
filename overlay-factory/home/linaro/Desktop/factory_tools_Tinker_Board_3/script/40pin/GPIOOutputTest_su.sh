#!/bin/bash -e

PIN="$1"
PULL="$2"

sudo su -c "sh GPIOOutputTest.sh "${PIN}" "${PULL}""
