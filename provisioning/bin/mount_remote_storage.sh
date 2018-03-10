#!/bin/sh

mkdir -p $REMOTE_STORAGE_LOCAL_DIR
chattr +i $REMOTE_STORAGE_LOCAL_DIR

echo "Mounting remote storage $REMOTE_USER@$REMOTE_HOST:$REMOTE_STORAGE_REMOTE_DIR at $REMOTE_STORAGE_LOCAL_DIR ..."

sshfs \
    $REMOTE_USER@$REMOTE_HOST:$REMOTE_STORAGE_REMOTE_DIR \
    $REMOTE_STORAGE_LOCAL_DIR \
    -o IdentityFile=/etc/remotebackup/remote_storage_key \
    -o port=${REMOTE_PORT:-22} \
    -o reconnect \
    -o ServerAliveInterval=30 \
    -o UserKnownHostsFile=/etc/remotebackup/known_hosts
