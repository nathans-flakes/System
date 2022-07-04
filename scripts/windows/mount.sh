#!/usr/bin/env bash
### Mounts the given, bitlocker encrypted, ntfs partition
###
### Arguments:
### 1. The device to mount
### 2. The path to mount at
### 3. The path to the recovery code file

###
## Setup
###
# Turn on the guard rails
set -eou pipefail
# Parse out the name of the device
DEVICE_NAME=$(basename $1)
# Make sure our /var directory exists
mkdir -p /var/dislocker/$DEVICE_NAME
# Make sure that the mountpoint exists
mkdir -p $2

###
## Mount dislocker
###
dislocker-fuse -V $1 -p"$(cat $3)" -- /var/dislocker/$DEVICE_NAME

###
## Mount the underlying ntfs partition
###
/run/wrappers/bin/mount -t ntfs-3g -o loop /var/dislocker/$DEVICE_NAME/dislocker-file $2
