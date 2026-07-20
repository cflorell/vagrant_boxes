#!/bin/bash -ex

if [ -z "${BOX_NAME:-}" ]; then
    echo "BOX_NAME is required." >&2
    exit 1
fi

template_file="$BOX_NAME.pkr.hcl"

if [ ! -f "$template_file" ]; then
    echo "Packer template '$template_file' does not exist." >&2
    exit 1
fi

# Use a directory on the main filesystem instead of /tmp (which may be limited)
export TMPDIR="$(pwd)/build-tmp"
mkdir -p "$TMPDIR"

curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub -o vagrant.pub
packer init "$template_file"
PACKER_LOG=1 PACKER_LOG_PATH="packer.log" packer build "$BOX_NAME".pkr.hcl

echo "Box '$BOX_NAME' built."