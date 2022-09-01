#!/usr/bin/env bash

rm -rf outputs
mkdir outputs

TOP_DIR=$(pwd)

make -f Makefiles/${IMPL_VIEW}/Makefile TESTNAME=${TEST_NAME} ARM_IP_DIR=${ARM_IP_DIR} \
    TOP_DIR=${TOP_DIR}
