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
  vm_name          = "fedora43"
  qemu_binary      = "qemu-system-x86_64"
  machine_type     = "q35"
  iso_url          = "https://download.fedoraproject.org/pub/fedora/linux/releases/${var.version}/Server/x86_64/iso/${var.iso}"
  iso_checksum     = "sha256:85837793bfa36db6bc709b4cecd2ec116951b87d9c53c3d95eb2fac8dcf7cf1f"
  cpus             = 2
  memory           = 2048
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  format           = "qcow2"
  disk_size        = 24576
  output_directory = "build"
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
    "<up><wait>",
    "e<wait>",
    "<down><down><end><wait>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora-ks.cfg",
    "<wait><f10>"
  ]
  qemuargs = [
    ["-netdev", "user,id=net0,hostfwd=tcp::2222-:22"],
    ["-device", "virtio-net-pci,netdev=net0"]
  ]
}


build {
  name = "Fedora${var.version}"

  sources = ["source.qemu.fedora"]

  post-processor "vagrant" {
    output = "fedora${var.version}.vagrant.box"
}
}