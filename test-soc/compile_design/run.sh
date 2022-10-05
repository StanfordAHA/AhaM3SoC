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

function show_msg
{
    #
    # Function accepts 1 argument:
    #   string containing a message to print

    echo "[Step: compile_design] ${1:-"No Message"}" 1>&2
}

# ==============================================================================
# Checks
# ------------------------------------------------------------------------------

# ==============================================================================
# Compile Design
# ------------------------------------------------------------------------------

show_msg "SOC_ONLY=${soc_only}, INCLUDE_XGCD=${INCLUDE_XGCD}"

make -f Makefiles/${SIMULATOR}/Makefile compile \
    TOP_DIR=${CUR_DIR} \
    ARM_IP_DIR=${ARM_IP_DIR} \
    AHA_IP_DIR=${AHA_IP_DIR} \
    SOC_ONLY=${soc_only} \
    TLX_FWD_DATA_LO_WIDTH=${TLX_FWD_DATA_LO_WIDTH} \
    TLX_REV_DATA_LO_WIDTH=${TLX_REV_DATA_LO_WIDTH} \
    IMPL_VIEW=${IMPL_VIEW} \
    PROCESS=${PROCESS}
