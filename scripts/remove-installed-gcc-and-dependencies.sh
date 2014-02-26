#!/bin/bash

####################################
# Remove all compiled data
####################################
rm -rf /opt/tmp/b-arm-cross/*
rm -rf /opt/tmp/b-native/*

rm -rf /opt/gcc-4.9-native/*
rm -rf /opt/gcc-4.9-arm/*

if [ -f /opt/tmp/did-reinstall-of-native-binutils ];
then
    rm /opt/tmp/did-reinstall-of-native-binutils
fi

if [ -f /opt/tmp/gcc-patches-applied ];
then
    rm /opt/tmp/gcc-patches-applied
fi
