#!/usr/bin/env bash

# ==============================================================================
# Variable Definitions
# ------------------------------------------------------------------------------

CUR_DIR=$(pwd)

# ==============================================================================
# Helper Functions
# ------------------------------------------------------------------------------

function error_exit
{
    #
    # Function accepts 1 argument:
    #   string containing descriptive error message
    #
    echo "run.sh: ${1:-"Unknown Error"}" 1>&2
    exit 1
}

# ==============================================================================
# Checks
# ------------------------------------------------------------------------------

# ==============================================================================
# Compile Design
# ------------------------------------------------------------------------------

make -C makefiles/${SIMULATOR}/Makefile compile \
    TOP_DIR=${CUR_DIR} \
    ARM_IP_DIR=${ARM_IP_DIR} \
    AHA_IP_DIR=${AHA_IP_DIR} \
    SOC_ONLY=${SOC_ONLY} \
    TLX_FWD_DATA_LO_WIDTH=${TLX_FWD_DATA_LO_WIDTH} \
    TLX_REV_DATA_LO_WIDTH=${TLX_REV_DATA_LO_WIDTH} \
    IMPL_VIEW=${IMPL_VIEW} \
    PROCESS=${PROCESS}
