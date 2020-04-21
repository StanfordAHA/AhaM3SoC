#!/usr/bin/env bash

make compile ARM_IP_DIR=${ARM_IP_DIR} AHA_IP_DIR=${AHA_IP_DIR} \
    SOC_ONLY=${soc_only} CGRA_RD_WS=${CGRA_RD_WS}
