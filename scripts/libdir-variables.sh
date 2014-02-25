#!/bin/bash

#############################################
# Set LD_LIBRARY_PATH
#############################################
#export LD_LIBRARY_PATH=$NATIVE_GCC_DIR/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ARM_GCC_DIR/lib:$NATIVE_GCC_DIR/lib:/lib32:/usr/lib32:$LD_LIBRARY_PATH
export LD_RUN_PATH=$ARM_GCC_DIR/lib:$NATIVE_GCC_DIR/lib:$LD_RUN_PATH
