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
box_path="./artifacts/$BOX_FILE"
storage_path="$BOX_STORAGE_DIR/$BOX_FILE"

if [ ! -f "$box_path" ]; then
    echo "Box artifact '$box_path' does not exist." >&2
    exit 1
fi

mkdir -p "$BOX_STORAGE_DIR"
cp "$box_path" "$storage_path.tmp"
mv "$storage_path.tmp" "$storage_path"

echo "Box '$BOX_NAME' published to '$storage_path'."

vagrant box add "$BOX_NAME" ./artifacts/"$BOX_FILE" --force
