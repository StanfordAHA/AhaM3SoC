#!/usr/bin/env bash

# ==============================================================================
# Variable Definitions
# ------------------------------------------------------------------------------

CUR_DIR=$(pwd)

# ==============================================================================
# Script
#-------------------------------------------------------------------------------

rm -rf ${CUR_DIR}/outputs
mkdir ${CUR_DIR}/outputs

git clone https://github.com/kavyasreedhar/xgcd.git
cd xgcd

python3.7 -m venv xgcd_env
source xgcd_env/bin/activate
python -m pip install --upgrade pip
pip install -e .

export TOP=$PWD
echo $TOP

cd xgcd
rm -rf functional_models
rm -rf physical_design
rm -rf utils
cd ..

python xgcd/hardware/extended_gcd/top/unique_gcd_wrappers.py

cd xgcd/hardware/extended_gcd/top/gcd_wrapper/rtl

cat AXItoSRAM.v AxiUnpacker.v AxiUnpackerCore.v GCDWrapper_512_1279.v GCDWrapper_255_1279.v RegFile.v > $TOP/all_wrapper_rtl.v

cd $TOP

git clone https://github.com/StanfordAHA/AhaM3SoC.git

cat UniqueGCDWrappers.v all_wrapper_rtl.v xgcd/hardware/extended_gcd/top/top_without_ro.sv /cad/synopsys/syn/L-2016.03-SP5-5/dw/sim_ver/DW01_csa.v AhaM3SoC/hardware/logical/AhaPlatformController/verilog/AhaResetSync.v > all_rtl.v

cp all_rtl.v ../outputs/xgcd_design.v
