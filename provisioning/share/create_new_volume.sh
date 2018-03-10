#!/bin/sh

VOLUME_FILE=$REMOTE_STORAGE_LOCAL_DIR/$CONTAINER_FILENAME

if [ -e $VOLUME_FILE ]; then
    echo "$VOLUME_FILE already exists. Aborting."
    exit 1
fi

read -p "Enter volume size (e.g. 10G): " VOLUME_SIZE

set -e
set -x

dd if=/dev/zero of=$VOLUME_FILE bs=1 count=0 seek=$VOLUME_SIZE
cryptsetup luksFormat $VOLUME_FILE
cryptsetup open $VOLUME_FILE $DATA_MAPPING_NAME
mkfs.ext4 -O metadata_csum,64bit /dev/mapper/$DATA_MAPPING_NAME
