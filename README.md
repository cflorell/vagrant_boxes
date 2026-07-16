# vagrant-boxes

Packer templates and build scripts for producing local Vagrant base boxes
(Arch Linux, Fedora 44, Ubuntu 26.04), used to verify Ansible playbooks in
the `ansible-nodes` repository

Each box is built fully unattended with QEMU/KVM, given a `vagrant`/`vagrant`
account with the standard [Vagrant insecure keypair](https://github.com/hashicorp/vagrant/tree/main/keys)
pre-authorized, and packaged into a `.box` file Vagrant can add directly.

## Layout

| Path | Purpose |
|---|---|
| `build.sh` | Generic build driver: runs `packer init`/`packer build` for `$BOX_NAME.pkr.hcl` and registers the result with `vagrant box add`. |
| `build_archlinux.sh`, `build_fedora.sh`, `build_ubuntu.sh` | Thin wrappers that set `BOX_NAME`/`BOX_FILE` and call `build.sh`. |
| `archlinux.pkr.hcl`, `fedora44.pkr.hcl`, `ubuntu2604.pkr.hcl` | Packer templates (QEMU builder + `vagrant` post-processor) for each distro. |
| `http/` | Files served to the VM during boot over Packer's HTTP server: Arch install script, Fedora kickstart (`fedora-ks.cfg`), Ubuntu autoinstall cloud-init (`user-data`/`meta-data`). |
| `publish_box.sh` | Copies a built box from `artifacts/` to a shared storage directory and re-adds it to the local Vagrant install. |
| `vagrant.pub` | Vagrant's public key, fetched fresh by `build.sh` and injected into each image's `authorized_keys`. |
| `artifacts/` | Output directory for built `.box` files (git-ignored). |
| `build-tmp/`, `build/`, `packer_cache/`, `packer.log` | Packer working/output/log directories (git-ignored). |
| `.gitlab-ci.yml` | GitLab CI pipeline that builds (and, on `main`, publishes) all three boxes. |

## Requirements

- [Packer](https://developer.hashicorp.com/packer) with the `qemu` and `vagrant` plugins
- QEMU/KVM (`qemu-system-x86_64`, hardware acceleration enabled)
- [Vagrant](https://developer.hashicorp.com/vagrant)
- `curl`

## Building a box

Run one of the per-distro wrappers:

```bash
./build_archlinux.sh   # -> artifacts/archlinux.vagrant.box, registered as "archlinux"
./build_fedora.sh      # -> artifacts/fedora44.vagrant.box, registered as "fedora44"
./build_ubuntu.sh      # -> artifacts/ubuntu26.04.vagrant.box, registered as "ubuntu2604"
```

Each wrapper just sets `BOX_NAME` and `BOX_FILE` and delegates to `build.sh`,
which can also be invoked directly for a custom template:

```bash
BOX_NAME=<template-name-without-.pkr.hcl> ./build.sh
```

`build.sh` downloads the current Vagrant insecure public key, boots the ISO
headless under QEMU, waits for the unattended installer to finish, and
produces `artifacts/<box>.vagrant.box` via Packer's `vagrant` post-processor.
The result is then added to the local Vagrant box collection with
`vagrant box add --force`, so the freshly built box is ready to use
immediately.

## Publishing a box

`publish_box.sh` copies a built artifact to a shared location (default
`/mnt/Storage3/boxes`, override with `BOX_STORAGE_DIR`) and re-registers it
with Vagrant:

```bash
BOX_NAME=archlinux BOX_FILE=archlinux.vagrant.box ./publish_box.sh
```

## CI

`.gitlab-ci.yml` defines one job per distro (`build_archlinux`,
`build_fedora`, `build_ubuntu`) that runs on merge requests and manual web
triggers, on a runner tagged `ansible`. On pushes to `main`, each job also
runs `publish_box.sh` to push the box to shared storage.
