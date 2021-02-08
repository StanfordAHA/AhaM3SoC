#!/usr/bin/env bash
ARM_IP_DIR=${GATE_LEVEL_DIR}

ln -s $ARM_IP_DIR inputs/power_files
pt_shell -f ptpx.tcl | tee logs/pt.log 

