#!/bin/sh

export CONTAINER_FILENAME=data
export CRYPTSETUP_KEY_CACHE=/run/remotebackup
export DATA_MAPPING_NAME=data
export INNER_VOLUME_STORAGE_DIR=/backups
export LOCAL_DECRYPTED_DIR=/data
export LOCAL_SOURCE_DIR=/source
export PATH=$PATH:/provisioning/bin
export REMOTE_STORAGE_LOCAL_DIR=/remote-storage
