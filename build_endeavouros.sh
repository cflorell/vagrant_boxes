#!/bin/bash -ex

BOX_NAME="endeavouros"
BOX_FILE="endeavouros.vagrant.box"
: "${ENDEAVOUROS_ISO_URL:?Set ENDEAVOUROS_ISO_URL to the EndeavourOS ISO URL}"
: "${ENDEAVOUROS_ISO_CHECKSUM:?Set ENDEAVOUROS_ISO_CHECKSUM to the ISO checksum, for example sha256:<checksum>}"

vagrant box remove "$BOX_NAME" --force || true
PACKER_LOG=1 PACKER_LOG_PATH="packer.log" packer build \
  -var "iso_url=${ENDEAVOUROS_ISO_URL}" \
  -var "iso_checksum=${ENDEAVOUROS_ISO_CHECKSUM}" \
  endeavouros.pkr.hcl
vagrant box add --name "$BOX_NAME" "$BOX_FILE" --force

echo "Box '$BOX_NAME' rebuilt and re-added to Vagrant."
