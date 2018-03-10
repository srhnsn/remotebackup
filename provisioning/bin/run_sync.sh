#!/bin/sh

. /etc/profile

set -e
set -u
set -x

BACKUPS_DIR="$LOCAL_DECRYPTED_DIR$INNER_VOLUME_STORAGE_DIR"
CURRENT_SYMLINK="$BACKUPS_DIR/current"
WORK_DIR="$BACKUPS_DIR/incomplete"
DEST_DIR="$BACKUPS_DIR/$(date +%Y-%m-%d)"

if [ -e "$DEST_DIR" ]; then
    echo "error: destination directory ($DEST_DIR) already exists"
    exit 1
fi

if [ ! -e "$WORK_DIR" ]; then
    mkdir "$WORK_DIR"
fi

FIND_RESULTS=$(find "$BACKUPS_DIR" -maxdepth 1 -regex "$BACKUPS_DIR/[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]" -type d)
RSYNC_LINK_DESTS=

for f in $FIND_RESULTS; do
    RSYNC_LINK_DESTS="$RSYNC_LINK_DESTS --link-dest $f"
done

rsync \
    --archive \
    --delete \
    --human-readable \
    --itemize-changes \
    --no-group \
    --no-owner \
    --no-perms \
    --progress \
    --verbose \
    $RSYNC_LINK_DESTS \
    $LOCAL_SOURCE_DIR/ \
    $WORK_DIR

mv "$WORK_DIR" "$DEST_DIR"

if [ -e "$CURRENT_SYMLINK" ]; then
    rm "$CURRENT_SYMLINK"
fi

ln -s "$DEST_DIR" "$CURRENT_SYMLINK"
