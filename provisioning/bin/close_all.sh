#!/bin/sh

umount $LOCAL_DECRYPTED_DIR
cryptsetup close $DATA_MAPPING_NAME
umount $REMOTE_STORAGE_LOCAL_DIR
