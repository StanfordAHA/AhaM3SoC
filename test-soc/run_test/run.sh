#!/usr/bin/env bash

CXDT=`readlink -f inputs/CXDT.bin`
XCELIUMD=`readlink -f inputs/xcelium.d`

MAX_CYCLE="10000000"

ln -s ${CXDT} CXDT.bin
ln -s ${XCELIUMD} xcelium.d

touch image.hex
echo "run" > commands.tcl
echo "exit" >> commands.tcl

xrun +MAX_CYCLE=${MAX_CYCLE} -R -input commands.tcl | tee outputs/xrun_run_${TEST_NAME}.log
