#!/bin/sh

cd /home/build/jenkins
git fetch origin
git clean -fd 
git reset --hard remotes/origin/android-7.0
exit 0
