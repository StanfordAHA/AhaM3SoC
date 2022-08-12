#!/usr/bin/env bash

rm -rf outputs
mkdir outputs
make -f Makefile_${IMPL_VIEW} TESTNAME=${TEST_NAME} ARM_IP_DIR=${ARM_IP_DIR}
