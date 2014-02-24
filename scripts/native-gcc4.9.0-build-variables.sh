#!/bin/bash

#############################################
# Set native build variables
#############################################
export NATIVE_GCC_TARGET=x86_64-linux-gnu
export NATIVE_GCC_DIR=/opt/gcc-4.9-native
export NATIVE_GCC_BIN_PATH=$NATIVE_GCC_DIR/bin
export PATH=$NATIVE_GCC_BIN_PATH:$PATH
