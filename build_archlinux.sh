#!/bin/bash -ex

BOX_NAME="archlinux"
BOX_FILE="archlinux.vagrant.box"

vagrant box remove "$BOX_NAME" --force || true
PACKER_LOG=1 PACKER_LOG_PATH="packer.log" packer build archlinux.pkr.hcl
vagrant box add --name "$BOX_NAME" "$BOX_FILE" --force

echo "Box '$BOX_NAME' rebuilt and re-added to Vagrant."
