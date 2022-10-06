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

git clone git@github.com:thenextged/xgcd_stub.git

cat xgcd_stub/*.v > outputs/xgcd_design.v
