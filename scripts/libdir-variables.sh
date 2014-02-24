#!/bin/bash

#############################################
# Set LD_LIBRARY_PATH
#############################################
export LD_LIBRARY_PATH=$NATIVE_GCC_DIR/lib:$LD_LIBRARY_PATH
export LD_RUN_PATH=$NATIVE_GCC_DIR/lib:$LD_RUN_PATH
