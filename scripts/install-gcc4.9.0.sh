#!/bin/bash

# LOGFILE
LOGFILE="/home/vagrant/host/logs/install-gcc-$(date +%Y%m%d_%H%M).log"

source /home/vagrant/host/scripts/native-gcc4.9.0-build-variables.sh
source /home/vagrant/host/scripts/arm-gcc4.9.0-build-variables.sh
source /home/vagrant/host/scripts/libdir-variables.sh

echo "$(date) NATIVE_GCC_TARGET=$NATIVE_GCC_TARGET" >> $LOGFILE
echo "$(date) NATIVE_GCC_DIR=$NATIVE_GCC_DIR" >> $LOGFILE
echo "$(date) NATIVE_GCC_BIN_PATH=$NATIVE_GCC_BIN_PATH" >> $LOGFILE
echo "$(date) ARM_GCC_TARGET=$ARM_GCC_TARGET" >> $LOGFILE
echo "$(date) ARM_GCC_DIR=$ARM_GCC_DIR" >> $LOGFILE
echo "$(date) ARM_GCC_BIN_PATH=$ARM_GCC_BIN_PATH" >> $LOGFILE

echo "$(date) LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $LOGFILE
echo "$(date) LD_RUN_PATH=$LD_RUN_PATH" >> $LOGFILE

echo "$(date) PATH=$PATH" >> $LOGFILE

echo "$(date) Starting GCC install." >> $LOGFILE

# Set this to number of cpu cores + 1
CORES=5

# GIT VERSION (only takes effect during initial provisioning),
# that is the first time you run vagrant up
GIT_REVISION="2a9110cb500e6754c28864a6dfaed185b367516c"
#GCC_SNAPSHOT_URL="ftp://ftp.mpi-sb.mpg.de/pub/gnu/mirror/gcc.gnu.org/pub/gcc/snapshots/4.9-20140223/gcc-4.9-20140223.tar.bz2"
GCC_SNAPSHOT_URL="ftp://ftp.gwdg.de/pub/misc/gcc/snapshots/4.9-20140223/gcc-4.9-20140223.tar.bz2"
#############################################
# Installation of GNAT
#############################################
###
# Install basic dependencies
###
echo "$(date) Installing required packages with apt-get." >> $LOGFILE

sudo apt-get -y install automake autoconf gcc-4.5-base \
    build-essential make gcc g++ flex bison patch \
    texinfo libncurses5-dev libmpfr-dev libgmp3-dev libmpc-dev libzip-dev \
    python-dev libexpat1-dev libelf1 libelfg0 elfutils libppl9 libcloog-ppl0

# sudo apt-get -y install ia32-libs lib32gcc1 libc6-i386 lib32z1 lib32stdc++6 \
#     lib32asound2 lib32ncurses5 lib32gomp1 lib32z1-dev lib32bz2-dev \
#     g++-multilib gcc-multilib

echo "$(date) Finished installing required packages with apt-get." >> $LOGFILE

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
                      "http://isl.gforge.inria.fr/isl-0.11.2.tar.bz2");

declare -a PATCHES=("http://gcc.1065356.n5.nabble.com/attachment/1011154/1/0002-Added-enable-cross-gnattools-flag-for-bare-metal-env.patch"
                    "http://gcc.1065356.n5.nabble.com/attachment/1011154/0/0001-Set-the-target-for-a-bare-metal-environment.patch");

### Download software
echo "$(date) Downloading required source packages." >> $LOGFILE
for DOWNLOAD_URL in "${DOWNLOADS[@]}"
do
    FILE=$(basename $DOWNLOAD_URL)
    if [ ! -f /opt/tmp/$FILE ]; then
        echo "$(date) Downloading $FILE." >> $LOGFILE
        wget -nc -P /opt/tmp/ $DOWNLOAD_URL
    else
        echo "$(date) $FILE found, skipping." >> $LOGFILE
    fi
done
echo "$(date) Finished downloading required source packages." >> $LOGFILE

### Download GCC
# Using Github mirror instead of the "official" mirror because of better
# download speeds.
# Official: git://gcc.gnu.org/git/gcc.git (http://gcc.gnu.org/wiki/GitMirror)
# Inofficial: https://github.com/mirrors/gcc
# if [ ! -d /opt/tmp/src_unpacked/gcc ];
# then
#     echo "$(date) Cloning GCC git repository from github mirror (this will take some time, 1.11GB to download)." >> $LOGFILE
#     echo "Cloning GCC git repository from github mirror (this will take some time, 1.11GB to download), about 20 minutes in total with 100Mbit/s download speed limited by Github upload speed."
#     git clone https://github.com/mirrors/gcc /opt/tmp/src_unpacked/gcc
#     cd /opt/tmp/src_unpacked/gcc
#     echo "$(date) Changing to GIT revision $GIT_REVISION." >> $LOGFILE
#     git checkout $GIT_REVISION
#     echo "$(date) Finished cloning GCC git repository." >> $LOGFILE
# else
#     echo "$(date) GCC git clone already available in /opt/tmp/src_unpacked/gcc, skipping." >> $LOGFILE
# fi

if [ ! -d /opt/tmp/src_unpacked/gcc ];
then
    FILE=$(basename $GCC_SNAPSHOT_URL)
    DIR=$(basename $FILE .tar.bz2)

    echo "$(date) Downloading GCC snapshot $FILE from $GCC_SNAPSHOT_URL" >> $LOGFILE
    wget -nc -P /opt/tmp/ $GCC_SNAPSHOT_URL

    echo "$(date) Uncompressing $FILE to /opt/tmp/src_unpacked/$DIR." >> $LOGFILE
    tar -xvkf /opt/tmp/$FILE  -C /opt/tmp/src_unpacked

    echo "$(date) Renaming $DIR to gcc" >> $LOGFILE
    mv /opt/tmp/src_unpacked/$DIR /opt/tmp/src_unpacked/gcc
else
    echo "$(date) GCC already available in /opt/tmp/src_unpacked/gcc, skipping." >> $LOGFILE
fi

### Download patches
echo "$(date) Downloading required GCC patches." >> $LOGFILE
for PATCH_URL in "${PATCHES[@]}"
do
    PATCH=$(basename $PATCH_URL)
    if [ ! -f /opt/tmp/$PATCH ]; then
        echo "$(date) $PATCH not found, downloading..." >> $LOGFILE
        wget -nc -P /opt/tmp/ $PATCH_URL
    else
        echo "$(date) $PATCH found, skipping" >> $LOGFILE
    fi
done
echo "$(date) Finished downloading required GCC patches." >> $LOGFILE

#####################################
# Unpack all files
#####################################
echo "$(date) Uncompressing source packages." >> $LOGFILE
for DOWNLOAD_URL in "${DOWNLOADS[@]}"
do
    FILE=$(basename $DOWNLOAD_URL)
    # Remove all extensions from the filenames, only two different types in the
    # array DOWNLOADS.
    DIR=$(basename $FILE .tar.gz)
    DIR=$(basename $DIR .tar.bz2)

    if [ -f /opt/tmp/$FILE ] && [ ! -d /opt/tmp/src_unpacked/$DIR ];
    then
        echo "$(date) Uncompressing $FILE to /opt/tmp/src_unpacked/$DIR." >> $LOGFILE
        tar -xvkf /opt/tmp/$FILE  -C /opt/tmp/src_unpacked
    else
        echo "$(date) $FILE already already uncompressed in /opt/tmp/src_unpacked/$DIR, skipping." >> $LOGFILE
    fi
done
echo "$(date) Finished uncompressing source packages." >> $LOGFILE

### Final touch to set proper ownership to all files.
chown -R root:root /opt/tmp/src_unpacked

####################################
# Apply GCC patches
####################################
if [ ! -f /opt/tmp/gcc-patches-applied ]
then
    echo "$(date) Applying GCC patches." >> $LOGFILE
    cd /opt/tmp/src_unpacked/gcc
    patch -p1 < ../../0001-Set-the-target-for-a-bare-metal-environment.patch
    patch -p1 < ../../0002-Added-enable-cross-gnattools-flag-for-bare-metal-env.patch
    touch "/opt/tmp/gcc-patches-applied"
    echo "$(date) Finished applying GCC patches." >> $LOGFILE
else
    echo "$(date) GCC patches already applied, skipping." >> $LOGFILE
fi

####################################
# Build native GCC
####################################
ARCH=native

### GMP
PROG=b-gmp
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    ../../src_unpacked/gmp-4.3.2/configure --prefix=$NATIVE_GCC_DIR \
        --build=$NATIVE_GCC_TARGET --enable-cxx
    make -j$CORES
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

### MPFR
PROG=b-mpfr
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    ../../src_unpacked/mpfr-3.1.2/configure --build=$NATIVE_GCC_TARGET \
        --prefix=$NATIVE_GCC_DIR --with-gmp=$NATIVE_GCC_DIR
    make -j$CORES
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

### MPC
PROG=b-mpc
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    ../../src_unpacked/mpc-1.0.2/configure --build=$NATIVE_GCC_TARGET \
        --prefix=$NATIVE_GCC_DIR --with-gmp=$NATIVE_GCC_DIR \
        --with-mpfr=$NATIVE_GCC_DIR
    make -j$CORES
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

### ISL
PROG=b-isl
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    ../../src_unpacked/isl-0.11.2/configure --prefix=$NATIVE_GCC_DIR \
        --with-gmp-prefix=$NATIVE_GCC_DIR
    make -j$CORES
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

### CLOOG
PROG=b-cloog
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    ../../src_unpacked/cloog-0.18.1/configure --prefix=$NATIVE_GCC_DIR \
        --with-gmp-prefix=$NATIVE_GCC_DIR --with-isl-prefix=$NATIVE_GCC_DIR
    make -j$CORES
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

###  Binutils
PROG=b-binutils
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    ../../src_unpacked/binutils-2.24/configure --prefix=$NATIVE_GCC_DIR \
        --verbose --disable-nls --target=$NATIVE_GCC_TARGET \
        --enable-interwork --enable-multilib --disable-werror \
        --with-cloog=$NATIVE_GCC_DIR --with-isl=$NATIVE_GCC_DIR \
        --with-stage1-ldflags="-Wl,-rpath,/opt/gcc-4.9-native/lib" \
        --enable-cloog-backend=isl
    make -j$CORES
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

# ### QUIRK steps, extra steps to fix something unknown.
# if [ ! -f /opt/tmp/did-reinstall-of-native-binutils ]
# then
#     echo "$(date) [Quirk] Started with quirk fix." >> $LOGFILE
#     echo "$(date) [Quirk] Removing everything in /opt/gcc-4.9-native/*" >> $LOGFILE
#     # rm -rf /opt/gcc-4.9-native/*
#     cd /opt/tmp/b-native/b-gmp
#     echo "$(date) [Quirk] Installing b-gmp." >> $LOGFILE
#     make install
#     cd /opt/tmp/b-native/b-mpfr
#     echo "$(date) [Quirk] Installing b-mpfr." >> $LOGFILE
#     make install
#     cd /opt/tmp/b-native/b-mpc
#     echo "$(date) [Quirk] Installing b-mpc." >> $LOGFILE
#     make install
#     cd /opt/tmp/b-native/b-isl
#     echo "$(date) [Quirk] Installing b-isl." >> $LOGFILE
#     make install
#     cd /opt/tmp/b-native/b-cloog
#     echo "$(date) [Quirk] Installing b-cloog." >> $LOGFILE
#     make install
# 
#     # Re-compile binutils
#     echo "$(date) [Quirk] Recompiling binutils." >> $LOGFILE
#     cd /opt/tmp/b-native/b-binutils
#     ../../src_unpacked/binutils-2.24/configure --prefix=$NATIVE_GCC_DIR \
#         --verbose --disable-nls --target=$NATIVE_GCC_TARGET \
#         --enable-interwork --enable-multilib --disable-werror \
#         --with-cloog=$NATIVE_GCC_DIR --with-isl=$NATIVE_GCC_DIR \
#         --with-stage1-ldflags="-Wl,-rpath,/opt/gcc-4.9-native/lib" \
#         --enable-cloog-backend=isl
#     make -j$CORES
#     make install
#     echo "$(date) [Quirk] Finished recompiling binutils." >> $LOGFILE
#     touch /opt/tmp/did-reinstall-of-native-binutils
#     echo "$(date) [Quirk] Finished with quirk fix." >> $LOGFILE
# fi
# 
### GCC
PROG=b-gcc
if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
then
    echo "$(date) Compiling $ARCH $PROG." >> $LOGFILE
    mkdir -pv /opt/tmp/b-$ARCH/$PROG
    cd /opt/tmp/b-$ARCH/$PROG
    echo "$(date) Configuring $ARCH $PROG." >> $LOGFILE
    ../../src_unpacked/gcc/configure -v --with-pkgversion="BAP GCC native 4.9.0 $GIT_REVISION" \
        --with-bugurl=http://adv.bruhnspace.com/support \
        --enable-languages=c,c++,ada,objc,obj-c++ \
        --prefix=$NATIVE_GCC_DIR --enable-shared --with-system-zlib \
        --enable-threads=posix \
        --disable-werror --enable-checking=release --build=$NATIVE_GCC_TARGET \
        --disable-multilib \
        --host=x86_64-linux-gnu --target=x86_64-linux-gnu \
        --with-gmp=$NATIVE_GCC_DIR \
        --with-mpfr=$NATIVE_GCC_DIR \
        --with-mpc=$NATIVE_GCC_DIR \
        --with-isl=$NATIVE_GCC_DIR \
        --with-cloog=$NATIVE_GCC_DIR \
        --with-stage1-ldflags="-Wl,-rpath,/opt/gcc-4.9-native/lib"
    echo "$(date) Running make -j$CORES for $ARCH $PROG." >> $LOGFILE
    make -j$CORES
    echo "$(date) Running make make install for $ARCH $PROG." >> $LOGFILE
    make install
    echo "$(date) Finished compiling $ARCH $PROG." >> $LOGFILE
    cd ..
else
    echo "$(date) $ARCH $PROG already compiled, skipping." >> $LOGFILE
fi

echo "=========================================================================" >> $LOGFILE
echo "= $(date) Native GCC $GIT_REVISION compilation and installation finished." >> $LOGFILE
echo "=========================================================================" >> $LOGFILE
####################################
# Build GCC for ARM cross compilation
####################################
# ARCH=arm-cross
#
# ### GMP
# PROG=b-gmp
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/gmp-4.3.2/configure --prefix=$ARM_GCC_DIR \
#         --build=$NATIVE_GCC_TARGET --enable-cxx
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### MPFR
# PROG=b-mpfr
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/mpfr-3.1.2/configure --build=$NATIVE_GCC_TARGET \
#         --prefix=$ARM_GCC_DIR --with-gmp=$ARM_GCC_DIR
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### MPC
# PROG=b-mpc
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/mpc-1.0.2/configure --build=$NATIVE_GCC_TARGET \
#         --prefix=$ARM_GCC_DIR --with-gmp=$ARM_GCC_DIR --with-mpfr=$ARM_GCC_DIR
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### ISL
# PROG=b-isl
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/isl-0.11.2/configure --prefix=$ARM_GCC_DIR \
#         --with-gmp-prefix=$ARM_GCC_DIR \
#         --with-stage1-ldflags="-Wl,-rpath,$ARM_GCC_DIR/lib"
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### CLOOG
# PROG=b-cloog
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/cloog-0.18.1/configure --prefix=$ARM_GCC_DIR \
#         --with-gmp-prefix=$ARM_GCC_DIR --with-isl-prefix=$ARM_GCC_DIR
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ###  Binutils
# PROG=b-binutils
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/binutils-2.24/configure --prefix=$ARM_GCC_DIR \
#         --verbose --disable-nls --target=$ARM_GCC_TARGET --enable-interwork \
#         --enable-multilib --disable-werror --with-cloog=$ARM_GCC_DIR \
#         --with-isl=$ARM_GCC_DIR
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### GCC stage 2
# PROG=b-gcc-stage2
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/gcc/configure --target=$ARM_GCC_TARGET \
#         --prefix=$ARM_GCC_DIR --with-gnu-as --enable-multilib --with-gnu-ld \
#         --disable-nls --enable-languages=c --disable-threads --disable-libssp \
#         --enable-interwork --disable-shared --disable-lto \
#         --with-pkgversion="BAP ARM bare metal cross compiler gcc 4.9.0 stage2" \
#         --with-gmp=$ARM_GCC_DIR --with-mpfr=$ARM_GCC_DIR \
#         --with-mpc=$ARM_GCC_DIR --with-isl=$ARM_GCC_DIR \
#         --with-cloog=$ARM_GCC_DIR
#     make all-gcc -j$CORES
#     #TODO: Maybe make install here instead.
#     make install-gcc
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### GCC stage 3
# PROG=b-gcc-stage3
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/gcc/configure --enable-cross-gnattools \
#         --target=$ARM_GCC_TARGET --disable-nls \
#         --without-libiconv-prefix --disable-libffi --enable-checking=release \
#         --enable-interwork --enable-multilib --disable-libmudflap \
#         --disable-libssp --disable-libstdcxx-pch --with-gnu-as --with-gnu-ld \
#         --enable-languages=c,c++,ada --prefix=$ARM_GCC_DIR \
#         --with-bugurl="http://adv.bruhnspace.com/support" \
#         --with-pkgversion="BAP ARM bare metal cross compiler gcc 4.9.0 with C, C++, Ada" \
#         --with-newlib --with-headers=../../src_unpacked/newlib-2.0.0/newlib/libc/include \
#         --with-gmp=$ARM_GCC_DIR \
#         --with-mpfr=$ARM_GCC_DIR \
#         --with-mpc=$ARM_GCC_DIR \
#         --with-isl=$ARM_GCC_DIR \
#         --with-cloog=$ARM_GCC_DIR
#     make all-gcc -j$CORES
#     make install-gcc
#     cd ..
#     # Comming back here later on in two steps.
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### Newlib
# PROG=b-newlib
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/newlib-2.0.0/configure --target=$ARM_GCC_TARGET \
#         --prefix=$ARM_GCC_DIR --enable-interwork --enable-multilib \
#         --disable-nls --disable-shared --disable-threads \
#         --with-gnu-as --with-gnu-ld
#     make all -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
# 
# ### Back to GCC stage 3
# PROG=b-gcc-stage3
# cd /opt/tmp/b-$ARCH/$PROG
# make all-gcc -j$CORES
# make install-gcc
# 
# ### GDB
# PROG=b-gdb
# if [ ! -d /opt/tmp/b-$ARCH/$PROG ]
# then
#     echo "$ARCH $PROG not compiled, compiling..."
#     mkdir -pv /opt/tmp/b-$ARCH/$PROG
#     cd /opt/tmp/b-$ARCH/$PROG
#     ../../src_unpacked/gdb-7.7/configure --target=$ARM_GCC_TARGET \
#         --prefix=$ARM_GCC_DIR --enable-interwork --enable-multilib \
#         --disable-nls --disable-shared --disable-threads \
#         --with-gnu-as --with-gnu-ld
#     make -j$CORES
#     make install
#     cd ..
# else
#     echo "$ARCH $PROG already compiled, skipping."
# fi
