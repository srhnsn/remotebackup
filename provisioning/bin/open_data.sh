#!/bin/bash

DEVICE_PATH=/dev/mapper/$DATA_MAPPING_NAME

OPEN_CMD="cryptsetup open $REMOTE_STORAGE_LOCAL_DIR/$CONTAINER_FILENAME $DATA_MAPPING_NAME"
MOUNT_CMD="mount -o journal_checksum $DEVICE_PATH $LOCAL_DECRYPTED_DIR"

cache_key () {
    read -s -p "Enter password: " volume_password
    echo

    touch "$CRYPTSETUP_KEY_CACHE"
    chmod u=rw,go= "$CRYPTSETUP_KEY_CACHE"

    echo "$volume_password" > "$CRYPTSETUP_KEY_CACHE"
}

main () {
    if [ -f "$CRYPTSETUP_KEY_CACHE" ]; then
        open_with_cached_key
        return
    fi

    read -p "Cache password? [yN] " cache_password

    if [ "$cache_password" = "y" ]; then
        cache_key
        open_with_cached_key
    else
        open_without_cache
    fi
}

mount_opened_volume () {
    if [ ! -e "$DEVICE_PATH" ]; then
        echo "Cannot mount $DEVICE_PATH, path does not exist"
        exit 1
    fi

    mkdir -p "$LOCAL_DECRYPTED_DIR"
    chattr +i "$LOCAL_DECRYPTED_DIR"

    echo "Mounting opened file at $LOCAL_DECRYPTED_DIR ..."
    $($MOUNT_CMD)

    if [ $? -eq 0 ]; then
        return
    fi

    fsck -vy "$DEVICE_PATH"
    $($MOUNT_CMD)
}

open_device () {
    echo "Opening encrypted file $REMOTE_STORAGE_LOCAL_DIR/$CONTAINER_FILENAME ..."
    $($OPEN_CMD)
}

open_without_cache () {
    open_device

    if [ $? -eq 0 ]; then
        mount_opened_volume
    fi
}

open_with_cached_key () {
    cat "$CRYPTSETUP_KEY_CACHE" | open_device

    if [ $? -eq 0 ]; then
        mount_opened_volume
    else
        rm "$CRYPTSETUP_KEY_CACHE"
    fi
}

main
