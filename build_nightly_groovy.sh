#!/bin/bash

if [ -d /home/build/.ccache ]; then
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export CCACHE_DIR=/home/build/.ccache
fi

export ROM_BUILDTYPE=SECURITY_RELEASE
export BUILD_WITH_COLORS=0
# for local repo
export PATH=/home/build/bin:$PATH

DEVICE=$device

if [ -z $DEVICE ]; then
    echo DEVICE not set
    exit 1
fi

echo USER=$USER
echo DEVICE=$DEVICE
echo CCACHE_DIR=$CCACHE_DIR
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

cd /home/build/omni-6
repo sync -d -c -f --force-sync -j16
rm -rf out

#use non-public keys to sign ROMs - keys not in git for obvious reasons
cp /home/build/.keys/* ./build/target/product/security

. build/envsetup.sh
brunch $DEVICE

if [ $? -eq 0 ]; then
    cd /home/build/jenkins-android-6.0
    source upload_build.sh
#    /home/build/delta/omnidelta.sh $DEVICE
else
    exit 1
fi

exit 0
