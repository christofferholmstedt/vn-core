#!/bin/bash

#############################################
# Set ARM cross compile build variables
#############################################
export ARM_GCC_TARGET=arm-none-eabi
export ARM_GCC_DIR=/opt/gcc-4.9-arm
export ARM_GCC_BIN_PATH=$ARM_GCC_DIR/bin
export PATH=$ARM_GCC_BIN_PATH:$PATH
