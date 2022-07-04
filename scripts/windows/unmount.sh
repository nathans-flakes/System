#!/usr/bin/env bash
### Unmounts the given, bitlocker encrypted, ntfs partition
###
### Arguments:
### 1. The device to mount
### 2. The path to mount at

###
## Setup
###
# Turn on the guard rails
set -xeou pipefail
# Parse out the name of the device
DEVICE_NAME=$(basename $1)

###
## Unmount the NTFS Partiion
###
umount $2

###
## Unmount the dislocker-file
###
/run/wrappers/bin/umount /var/dislocker/$DEVICE_NAME/
