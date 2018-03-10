#!/bin/sh

mount_remote_storage.sh

filename="$REMOTE_STORAGE_LOCAL_DIR/health-check"
touch "$filename"

if [ $? -ne 0 ]; then
    echo "$REMOTE_STORAGE_LOCAL_DIR does not seem to be correctly mounted"
    exit 1
fi

rm "$filename"

open_data.sh
