packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "iso_url" {
  type        = string
  description = "Arch Linux ISO URL."
  default     = "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "Arch Linux ISO checksum or checksum file URL."
  default     = "file:https://geo.mirror.pkgbuild.com/iso/latest/sha256sums.txt"
}

source "qemu" "archlinux" {
  vm_name          = "archlinux"
  qemu_binary      = "qemu-system-x86_64"
  machine_type     = "q35"
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  cpus             = 2
  memory           = 2048
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  format           = "qcow2"
  disk_size        = 51200
  output_directory = "build"
  accelerator      = var.qemu_accelerator
  headless         = true
  http_directory   = "http"
  ssh_password     = "vagrant"
  ssh_username     = "vagrant"
  ssh_timeout      = "30m"
  ssh_host         = "127.0.0.1"
  shutdown_command = "echo 'vagrant' | sudo -S /usr/bin/systemctl poweroff"
  shutdown_timeout = "5m"
  boot_wait        = "1s"
  boot_command = [
    "<enter><wait10><wait10><wait10>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/archlinux-install.sh<enter>",
    "/usr/bin/bash ./archlinux-install.sh<enter>"
  ]
}

build {
  name = "ArchLinux"

  sources = ["source.qemu.archlinux"]

  post-processor "vagrant" {
    output = "artifacts/archlinux.vagrant.box"
  }
}
