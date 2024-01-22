#!/bin/bash -e

PIN="$1"

sudo su -c "sh GPIOInputTest.sh "${PIN}""
