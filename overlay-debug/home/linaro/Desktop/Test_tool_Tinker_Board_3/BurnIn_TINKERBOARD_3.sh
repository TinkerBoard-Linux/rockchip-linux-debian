#!/bin/bash

version=4.11.20230926

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`/BurnIn_test

sudo $SCRIPTPATH/BurnIn.sh TINKERBOARD_3

