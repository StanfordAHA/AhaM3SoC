#!/usr/bin/env bash

CXDT=`readlink -f inputs/CXDT.bin`
XCELIUMD=`readlink -f inputs/xcelium.d`

MAX_SIM_TIME="60000us"

ln -s ${CXDT} CXDT.bin
ln -s ${XCELIUMD} xcelium.d

touch image.hex
echo "run" > commands.tcl
echo "exit" >> commands.tcl

xrun -R -input commands.tcl | tee outputs/xrun_run_${TEST_NAME}.log
