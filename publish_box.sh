#!/bin/bash -ex

if [ -z "${BOX_NAME:-}" ]; then
    echo "BOX_NAME is required." >&2
    exit 1
fi

if [ -z "${BOX_FILE:-}" ]; then
    echo "BOX_FILE is required." >&2
    exit 1
fi

BOX_STORAGE_DIR="${BOX_STORAGE_DIR:-/mnt/Storage3/boxes}"
BOX_STORAGE_GROUP="${BOX_STORAGE_GROUP:-gitlab-runner-storage}"
box_path="./artifacts/$BOX_FILE"
storage_path="$BOX_STORAGE_DIR/$BOX_FILE"

if [ ! -f "$box_path" ]; then
    echo "Box artifact '$box_path' does not exist." >&2
    exit 1
fi

# Storage3 is an NFS share, and this NFS server only honors the caller's
# primary GID for group-ownership permission checks, not supplementary
# groups — gitlab-runner is only a supplementary member of
# BOX_STORAGE_GROUP, so writes must run with it as the effective primary
# group via `sg`, or they fail with "Permission denied".
sg "$BOX_STORAGE_GROUP" -c "mkdir -p '$BOX_STORAGE_DIR' && cp '$box_path' '$storage_path.tmp' && mv '$storage_path.tmp' '$storage_path'"

echo "Box '$BOX_NAME' published to '$storage_path'."

vagrant box add "$BOX_NAME" ./artifacts/"$BOX_FILE" --force
