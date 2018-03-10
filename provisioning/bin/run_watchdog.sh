#!/bin/sh

CHECK_INTERVAL=30

. /etc/profile

handle_directory_problem () {
    echo "Closing all remote connections"

    systemctl stop rb_sync
    close_all.sh

    if [ ! -f "$CRYPTSETUP_KEY_CACHE" ]; then
        exit
    fi

    echo "Attempting to reconnect"
    mount_and_open.sh

    if [ $? -eq 0 ]; then
        echo "Starting sync process and resuming health checks"
        systemctl start rb_sync
    else
        echo "Reconnection attempt failed, trying again in $CHECK_INTERVAL seconds"
    fi
}

is_directory_ok () {
    filename=$1/health-check
    touch $filename

    if [ $? -ne 0 ]; then
        return 1
    fi

    rm $filename
    return 0
}

main () {
    while [ true ]; do
        if ! is_directory_ok $LOCAL_DECRYPTED_DIR; then
            echo "$LOCAL_DECRYPTED_DIR does not seem to be functioning normally"
            handle_directory_problem

        # elif ! is_directory_ok $REMOTE_STORAGE_LOCAL_DIR; then
        #     echo "$REMOTE_STORAGE_LOCAL_DIR does not seem to be functioning normally"
        #     handle_directory_problem
        fi

        sleep $CHECK_INTERVAL
    done
}

main
