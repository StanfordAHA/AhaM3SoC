#!/usr/bin/env bash

ROM_IMAGE=`readlink -f inputs/ROM.hex`
CXDT_IMAGE=`readlink -f inputs/CXDT.bin`
SIMV_BIN=`readlink -f inputs/simv`
SIMV_DAIDIR=`readlink -f inputs/simv.daidir`

MAX_SIM_TIME="200000000000"
MAX_CYCLE="2000000000"

ln -s ${ROM_IMAGE} ROM.hex
ln -s ${CXDT_IMAGE} CXDT.bin
ln -s ${SIMV_BIN} simv
ln -s ${SIMV_DAIDIR} simv.daidir

echo "quit" > quit.do

./simv +vcs+lic+wait +vcs+flush+log +vcs+finish+${MAX_SIM_TIME} +vcs+initreg+0 \
    +VCD_ON \
    +MAX_CYCLE=${MAX_CYCLE} \
    -assert nopostproc < quit.do | tee outputs/SIM_run_${TEST_NAME}.log
