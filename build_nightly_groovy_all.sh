#!/bin/bash

if [ -d /ccache ]; then
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export CCACHE_DIR=/ccache
fi
if [ -d /home/build/.ccache ]; then
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export CCACHE_DIR=/home/build/.ccache
fi

export BUILD_WITH_COLORS=0
# for local repo
export PATH=/home/build/bin:$PATH

DEVICE=$device
BUILDTYPE=$build_type
ROOTDIR=$root_dir
SCRIPTDIR=$script_dir
UPLOAD=$upload
DELTA=$delta
JAVA=$java

if [ -z $DEVICE ]; then
    echo DEVICE not set
    exit 1
fi

if [ -z $BUILDTYPE ]; then
    echo BUILDTYPE not set
    exit 1
fi

if [ -z $ROOTDIR ]; then
    echo ROOTDIR not set
    exit 1
fi

if [ -z $SCRIPTDIR ]; then
    echo SCRIPTDIR not set
    exit 1
fi

if [ -z $JAVA ]; then
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
else
    export JAVA_HOME=$JAVA
fi

export ROM_BUILDTYPE=$BUILDTYPE

echo USER=$USER
echo DEVICE=$DEVICE
echo CCACHE_DIR=$CCACHE_DIR
echo ROM_BUILDTYPE=$ROM_BUILDTYPE
echo ROOTDIR=$ROOTDIR
echo SCRIPTDIR=$SCRIPTDIR
echo UPLOAD=$UPLOAD
echo DELTA=$DELTA
echo JAVA_HOME=$JAVA_HOME

cd $ROOTDIR

#repo sync -j48
#fixme: uncommitted changes suddenly appear
cd .repo/manifests
git reset --hard
git clean -fd
cd ../..
cd .repo/repo
git reset --hard
git clean -fd
cd ../..
repo forall -c "git reset --hard" -j48
repo forall -c "git clean -fd" -j48
repo sync --force-sync -cdf -j48
rm -rf out

#use non-public keys to sign ROMs - keys not in git for obvious reasons
cp /home/build/.keys/* ./build/target/product/security

. build/envsetup.sh
brunch $DEVICE

if [ $? -eq 0 ]; then
    if [ -n $UPLOAD ]; then
        cd $SCRIPTDIR
        source upload_nightly.sh
    fi
    if [ -n $DELTA ]; then
        /home/build/delta/omnidelta.sh $DEVICE
    fi
else
    exit 1
fi
