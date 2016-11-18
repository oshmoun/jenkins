#!/bin/bash
DEVICE=$CUSTOM_BUILD

# Create dir if needed
ssh -p 9122 omnirom@207.244.74.108 "mkdir -p /var/www/dl.omnirom.org/$DEVICE" 2>/dev/null >/dev/null

# Upload file (in a background process?!)
echo Uploading...
time scp -P 9122 $OUT/omni*-*.zip* omnirom@207.244.74.108:/var/www/dl.omnirom.org/$DEVICE/
