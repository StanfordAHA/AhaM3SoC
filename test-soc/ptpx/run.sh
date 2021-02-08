#!/usr/bin/env bash
ARM_IP_DIR=${GATE_LEVEL_DIR}

ln -s $ARM_IP_DIR inputs/power_files
cp inputs/run.saif run.saif
unlink inputs/power_files/run.saif
cp inputs/run.saif inputs/power_files/run.saif
pt_shell -f ptpx.tcl | tee logs/pt.log 

