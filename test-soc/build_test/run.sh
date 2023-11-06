#!/usr/bin/env bash

rm -rf outputs
mkdir outputs

TOP_DIR=$(pwd)

cp Makefiles/${TEST_VIEW}/Makefile .

make TESTNAME=${TEST_NAME} ARM_IP_DIR=${ARM_IP_DIR} TOP_DIR=${TOP_DIR}
