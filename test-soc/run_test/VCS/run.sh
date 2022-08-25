#!/usr/bin/env bash

ROM_IMAGE=`readlink -f inputs/ROM.hex`
SIMV_BIN=`readlink -f inputs/simv`
SIMV_DAIDIR=`readlink -f inputs/simv.daidir`

MAX_SIM_TIME="20000000000"
MAX_CYCLE="200000000"

ln -s ${ROM_IMAGE} ROM.hex
ln -s ${SIMV_BIN} simv
ln -s ${SIMV_DAIDIR} simv.daidir

echo "quit" > quit.do

./simv +vcs+lic+wait +vcs+flush+log +vcs+finish+${MAX_SIM_TIME} \
    +VCD_ON \
    +MAX_CYCLE=${MAX_CYCLE} \
    -assert nopostproc < quit.do | tee outputs/SIM_run_${TEST_NAME}.log
