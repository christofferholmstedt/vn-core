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
# Create required directories
#####################################
mkdir -pv /opt/tmp/src_unpacked
mkdir -pv /opt/tmp/b-native
mkdir -pv /opt/tmp/b-arm-cross
mkdir -pv /opt/gcc-4.9-native
mkdir -pv /opt/gcc-4.9-arm

#####################################
# Download required sources
#####################################
# Is it perhaps possible to download these files from the GNU GCC repository?
# All files from one archive would make it a little bit easier to write this
# script.
declare -a DOWNLOADS=("https://gmplib.org/download/gmp/gmp-4.3.2.tar.bz2"
                      "http://www.mpfr.org/mpfr-3.1.2/mpfr-3.1.2.tar.bz2"
                      "ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz"
                      "http://www.bastoul.net/cloog/pages/download/cloog-0.18.1.tar.gz"
                      "http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2"
                      "ftp://ftp.funet.fi/pub/mirrors/sources.redhat.com/pub/gdb/releases/gdb-7.7.tar.bz2"
                      "ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz"
                      "http://isl.gforge.inria.fr/isl-0.11.1.tar.bz2");

declare -a PATCHES=("http://gcc.1065356.n5.nabble.com/attachment/1011154/1/0002-Added-enable-cross-gnattools-flag-for-bare-metal-env.patch"
                    "http://gcc.1065356.n5.nabble.com/attachment/1011154/0/0001-Set-the-target-for-a-bare-metal-environment.patch");

### Download software
for DOWNLOAD_URL in "${DOWNLOADS[@]}"
do
    FILE=$(basename $DOWNLOAD_URL)
    if [ ! -f /opt/tmp/$FILE ]; then
        echo "$FILE not found, downloading..."
        wget -nc -P /opt/tmp/ $DOWNLOAD_URL
    else
        echo "$FILE found, skipping downloading."
    fi
done

### Download GCC
# Using Github mirror instead of the "official" mirror because of better
# download speeds.
# Official: git://gcc.gnu.org/git/gcc.git (http://gcc.gnu.org/wiki/GitMirror)
# Inofficial: https://github.com/mirrors/gcc
if [ ! -d /opt/tmp/src_unpacked/gcc ];
then
    echo "GCC git clone was not found, cloning to /opt/tmp/src_unpacked/gcc"
    git clone https://github.com/mirrors/gcc /opt/tmp/src_unpacked/gcc
    # Using daily bump commit from 20120224
    # http://gcc.gnu.org/git/?p=gcc.git;a=commit;h=2a9110cb500e6754c28864a6dfaed185b367516c
    cd /opt/tmp/src_unpacked/gcc
    git checkout 2a9110cb500e6754c28864a6dfaed185b367516c
else
    echo "GCC git clone already available in /opt/tmp/src_unpacked/gcc, skipping."
fi

### Download patches
for PATCH_URL in "${PATCHES[@]}"
do
    PATCH=$(basename $PATCH_URL)
    if [ ! -f /opt/tmp/$PATCH ]; then
        echo "$PATCH not found, downloading..."
        wget -nc -P /opt/tmp/ $PATCH_URL
    else
        echo "$PATCH found, skipping downloading."
    fi
done

#####################################
# Unpack all files
#####################################
for DOWNLOAD_URL in "${DOWNLOADS[@]}"
do
    FILE=$(basename $DOWNLOAD_URL)
    # Remove all extensions from the filenames, only two different types in the
    # array DOWNLOADS.
    DIR=$(basename $FILE .tar.gz)
    DIR=$(basename $DIR .tar.bz2)

    if [ -f /opt/tmp/$FILE ] && [ ! -d /opt/tmp/src_unpacked/$DIR ];
    then
        echo "$FILE found, unpacking to /opt/tmp/src_unpacked/$DIR"
        tar -xvkf /opt/tmp/$FILE  -C /opt/tmp/src_unpacked
    else
        echo "$FILE already available in /opt/tmp/src_unpacked/$DIR"
    fi
done

### Final touch to set proper ownership to all files.
chown -R root:root /opt/tmp/src_unpacked

####################################
# OLD #1 - Download required sources
####################################
# mkdir -pv /opt/arm/src/orig
# cd /opt/arm/src/orig
#
# # Some pre-downloading is required due to AdaCores CDN structure with files
# # only available at different hashes.
# # Go to http://libre.adacore.com/download/ and download the following three
# # packages in advance, before starting vagrant.
#
# declare -a ADACORE_FILES=("gcc-4.5-gpl-2012-src.tgz"
#                           "gdb-7.4-gpl-2012-src.tgz"
#                           "gnat-gpl-2012-src.tgz");
#
# declare -a ALL_FILES=("${ADACORE_FILES[@]}");
#
# for ADACORE_FILE in "${ADACORE_FILES[@]}"
# do
#     # Check if file has been pre-downloaded
#     if [ ! -f /home/vagrant/host/downloads/$ADACORE_FILE ];
#     then
#         echo "$ADACORE_FILE not found!"
#         exit 1 # Abort if file is missing.
#
#     # Check if file has been pre-download and file has been copied to
#     # /opt/arm/src/orig/
#     elif [ -f /home/vagrant/host/downloads/$ADACORE_FILE ] && [ ! -f /opt/arm/src/orig/$ADACORE_FILE ];
#     then
#         echo "$ADACORE_FILE found, copying to /opt/arm/src/orig/"
#         cp -v /home/vagrant/host/downloads/$ADACORE_FILE /opt/arm/src/orig/
#     else
#         echo "$ADACORE_FILE has already been copied to /opt/arm/src/orig/ ,skipping..."
#     fi
# done
#####################################
# OLD #2 - Download required sources
#####################################
# mkdir -pv /opt/arm/src/orig
# cd /opt/arm/src/orig
#
# declare -a GNU_FILES=("http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz"
#                       "http://ftp.gnu.org/gnu/gmp/gmp-5.1.3.tar.gz"
#                       "http://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz"
#                       "http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz");
#
# for GNU_URL in "${GNU_FILES[@]}"
# do
#     GNU_FILE=$(basename $GNU_URL)
#     ALL_FILES+=("$GNU_FILE")
#     if [ ! -f /opt/arm/src/orig/$GNU_FILE ]; then
#         echo "$GNU_FILE not found, downloading..."
#         wget -P /opt/arm/src/orig/ $GNU_URL
#     else
#         echo "$GNU_FILE found, skipping downloading."
#     fi
# done
#####################################
# OLD - Unpack all files
#####################################
# mkdir -pv /opt/arm/src/src
# cd /opt/arm/src/src/
#
# for DOWNLOADED_FILE in "${ALL_FILES[@]}"
# do
#     if [ -f "/opt/arm/src/orig/$DOWNLOADED_FILE" ];
#     then
#         tar -xvf /opt/arm/src/orig/$DOWNLOADED_FILE
#     fi
# done
#
# chown -R root:root /opt/arm/src/src/
