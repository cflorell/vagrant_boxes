packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      source = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}
variable "version" {
  type    = string
  default = "44"
}

variable "iso" {
  type    = string
  default = "Fedora-Server-dvd-x86_64-44-1.7.iso"
}

source "qemu" "fedora" {
  vm_name          = "fedora${var.version}"
  qemu_binary      = "qemu-system-x86_64"
  machine_type     = "q35"
  iso_url          = "https://download.fedoraproject.org/pub/fedora/linux/releases/${var.version}/Server/x86_64/iso/${var.iso}"
  iso_checksum     = "sha256:85837793bfa36db6bc709b4cecd2ec116951b87d9c53c3d95eb2fac8dcf7cf1f"
  cpus             = 2
  memory           = 2048
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  format           = "qcow2"
  disk_size        = 51200
  output_directory = "build"
  accelerator      = "kvm"
  headless         = true
  http_directory   = "http"
  ssh_password     = "vagrant"
  ssh_username     = "vagrant"
  ssh_timeout      = "20m"
  ssh_host         = "127.0.0.1"
  shutdown_command = "echo 'vagrant' | sudo -S /usr/bin/systemctl poweroff"
  shutdown_timeout = "5m"
  boot_wait        = "10s"
  boot_command = [
    "<up><wait>",
    "e<wait>",
    "<down><down><end><wait>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora-ks.cfg",
    "<wait><f10>"
  ]
}


build {
  name = "Fedora${var.version}"

  sources = ["source.qemu.fedora"]

  post-processor "vagrant" {
    output = "artifacts/fedora${var.version}.vagrant.box"
}
}
