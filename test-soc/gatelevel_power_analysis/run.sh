#!/usr/bin/env bash

# Environment variables
export reports=0
export chkpt=0

# clean up the logs and reports
if [ -d "logs" ]; then
    rm -rf reports
fi
if [ -d "reports" ]; then
    rm -rf reports
fi
mkdir -p logs
mkdir -p reports

# Run the power analysis
pt_shell -f ./scripts/ptpx.tcl | tee logs/pt.log 
