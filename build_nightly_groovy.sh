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

export ROM_BUILDTYPE=NIGHTLY
export BUILD_WITH_COLORS=0
# for local repo
export PATH=/home/build/bin:$PATH
export ANDROID_JACK_VM_ARGS="-Xmx4g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

DEVICE=$device

if [ -z $DEVICE ]; then
    echo DEVICE not set
    exit 1
fi

echo USER=$USER
echo DEVICE=$DEVICE
echo CCACHE_DIR=$CCACHE_DIR
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

cd /home/build/omni-7

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
# we should consider make installclean to decrease build times
rm -rf out

#use non-public keys to sign ROMs - keys not in git for obvious reasons
cp /home/build/.keys/* ./build/target/product/security

. build/envsetup.sh
brunch $DEVICE

########## Temporary exit - remove when nightlies are ready ##########
exit 0
########## Temporary exit - remove when nightlies are ready ##########

if [ $? -eq 0 ]; then
	source upload_nightly.sh
	/home/build/delta/omnidelta.sh $DEVICE
else
	exit 1
fi
