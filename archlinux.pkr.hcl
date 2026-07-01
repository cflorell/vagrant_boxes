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
  disk_size        = 24576
  output_directory = "build"
  accelerator      = "kvm"
  headless         = false
  http_directory   = "http"
  ssh_password     = "vagrant"
  ssh_username     = "vagrant"
  ssh_timeout      = "60m"
  ssh_host         = "127.0.0.1"
  ssh_port         = 2222
  host_port_min    = 2222
  host_port_max    = 2222
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  boot_wait        = "10s"
  boot_command = [
    "e<wait>",
    "<down><down><end><wait>",
    " cow_spacesize=2G script=http://{{ .HTTPIP }}:{{ .HTTPPort }}/archlinux-install.sh",
    "<wait><f10>"
  ]
  qemuargs = [
    ["-netdev", "user,id=net0,hostfwd=tcp::2222-:22"],
    ["-device", "virtio-net-pci,netdev=net0"]
  ]
}

build {
  name = "ArchLinux"

  sources = ["source.qemu.archlinux"]

  post-processor "vagrant" {
    output = "archlinux.vagrant.box"
  }
}
