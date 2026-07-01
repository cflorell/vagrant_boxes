#!/bin/bash -ex

vagrant box remove "$BOX_NAME" --force || true
curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub -o vagrant.pub
PACKER_LOG=1 PACKER_LOG_PATH="packer.log" packer build "$BOX_NAME".pkr.hcl
vagrant box add --name "$BOX_NAME" "$BOX_FILE" --force

echo "Box '$BOX_NAME' built and re-added to Vagrant."