#!/usr/bin/env bash

CXDT=`readlink -f inputs/CXDT.bin`
XCELIUMD=`readlink -f inputs/xcelium.d`

MAX_CYCLE="20000000"

ln -s ${CXDT} CXDT.bin
ln -s ${XCELIUMD} xcelium.d

touch image.hex
echo "run" > commands.tcl
echo "exit" >> commands.tcl

# Change TLX init files here
user_name=$(whoami)
TLX_BITSTREAM="/sim/${user_name}/aham3soc_armip/software/testcodes/app_tlx_test/gaussian_different_width/width_256_bin/gaussian.bs"
TLX_APP_INPUT="/sim/${user_name}/aham3soc_armip/software/testcodes/app_tlx_test/gaussian_different_width/width_256_bin/gaussian_input.raw"
TLX_APP_GOLD="/sim/${user_name}/aham3soc_armip/software/testcodes/app_tlx_test/gaussian_different_width/width_256_bin/gaussian_output.raw"

# arguments:
# +VCD_ON                                       : enable waveform dumping
# +TLX_BITSTREAM=/path/to/bitstream/file.bs     : for TLX init
# +TLX_APP_INPUT=/path/to/application/input.raw : for TLX init
# +TLX_APP_GOLD=/path/to/application/gold.raw   : for TLX init
# +MAX_CYCLE=<cycles>                           : maximum simulation cycles to prevent hanging
# -unbuffered                                   : enable real-time simulation std out
# -R                                            : execute the simulation after compiling
# -input aaa.tcl                                : include other tcl file
xrun \
 +VCD_ON \
 +TLX_BITSTREAM=${TLX_BITSTREAM} \
 +TLX_APP_INPUT=${TLX_APP_INPUT} \
 +TLX_APP_GOLD=${TLX_APP_GOLD} \
 +MAX_CYCLE=${MAX_CYCLE} \
 -unbuffered \
 -R \
 -input commands.tcl \
 | tee outputs/xrun_run_${TEST_NAME}.log
