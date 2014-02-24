#!/bin/bash

#############################################
# Installation of GNAT
#############################################
###
# Install basic dependencies
###
sudo apt-get -y install gcc-4.5-base build-essential make gcc g++ flex bison patch \
    texinfo libncurses5-dev libmpfr-dev libgmp3-dev libmpc-dev libzip-dev \
    python-dev libexpat1-dev libelf1 libelfg0 elfutils libppl9 libcloog-ppl0

# libelf doesn't exist perhaps libelf1 or libelf-dev is correct?
# testing with "libelf1"

# libppl doesn't exist perhaps libppl9 or libppl-c4
# testing with "libppl9"

# libCLooG doesn't exist perhaps libcloog-ppl0 or libcloog-ppl1
# testing with "libcloog-ppl0" from main

#####################################
# Download required sources
#####################################
mkdir -pv /opt/arm/src/orig
cd /opt/arm/src/orig

# Some pre-downloading is required due to AdaCores CDN structure with files
# only available at different hashes.
# Go to http://libre.adacore.com/download/ and download the following three
# packages in advance, before starting vagrant.

declare -a ADACORE_FILES=("gcc-4.5-gpl-2012-src.tgz"
                          "gdb-7.4-gpl-2012-src.tgz"
                          "gnat-gpl-2012-src.tgz");

declare -a ALL_FILES=("${ADACORE_FILES[@]}");

for ADACORE_FILE in "${ADACORE_FILES[@]}"
do
    # Check if file has been pre-downloaded
    if [ ! -f /home/vagrant/host/downloads/$ADACORE_FILE ];
    then
        echo "$ADACORE_FILE not found!"
        exit 1 # Abort if file is missing.

    # Check if file has been pre-download and file has been copied to
    # /opt/arm/src/orig/
    elif [ -f /home/vagrant/host/downloads/$ADACORE_FILE ] && [ ! -f /opt/arm/src/orig/$ADACORE_FILE ];
    then
        echo "$ADACORE_FILE found, copying to /opt/arm/src/orig/"
        cp -v /home/vagrant/host/downloads/$ADACORE_FILE /opt/arm/src/orig/
    else
        echo "$ADACORE_FILE has already been copied to /opt/arm/src/orig/ , skipping..."
    fi
done

declare -a GNU_FILES=("http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz"
                      "http://ftp.gnu.org/gnu/gmp/gmp-5.1.3.tar.gz"
                      "http://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz"
                      "http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz");

for GNU_URL in "${GNU_FILES[@]}"
do
    GNU_FILE=$(basename $GNU_URL)
    ALL_FILES+=("$GNU_FILE")
    if [ ! -f /opt/arm/src/orig/$GNU_FILE ]; then
        echo "$GNU_FILE not found, downloading..."
        wget -P /opt/arm/src/orig/ $GNU_URL
    else
        echo "$GNU_FILE found, skipping downloading."
    fi
done

#####################################
# Unpack all files
#####################################
mkdir -pv /opt/arm/src/src
cd /opt/arm/src/src/

for DOWNLOADED_FILE in "${ALL_FILES[@]}"
do
    if [ -f "/opt/arm/src/orig/$DOWNLOADED_FILE" ];
    then
        tar -xvf /opt/arm/src/orig/$DOWNLOADED_FILE
    fi
done

chown -R root:root /opt/arm/src/src/

#####################################
# Patch binutils
#####################################
# wget 
