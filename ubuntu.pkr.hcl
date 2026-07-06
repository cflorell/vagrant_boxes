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
  default = "26.04"
}

source "qemu" "qcow2" {
  qemuargs = [
  ["-netdev", "user,id=net0,hostfwd=tcp::2222-:22"],
  ["-device", "virtio-net-pci,netdev=net0"]
]
  vm_name              = "ubuntu-2604-amd64"
  iso_url              = "https://releases.ubuntu.com/${var.version}/ubuntu-${var.version}-live-server-amd64.iso"
  iso_checksum         = "dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"
  memory               = 2048
  disk_image           = false
  output_directory     = "build"
  accelerator          = "kvm"
  disk_size            = 24567
  disk_interface       = "virtio"
  format               = "qcow2"
  net_device           = "virtio-net"
  boot_wait            = "1s"
  boot_command         = ["e<wait><down><down><down><end> autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<F10>"]
  http_directory       = "http"
  shutdown_command     = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "30m"
  ssh_host             = "127.0.0.1"
  ssh_port             = 2222
  host_port_min        = 2222
  host_port_max        = 2222
}

build {
  name = "Ubuntu${var.version}"
  sources = ["source.qemu.qcow2"]

  provisioner "file" {
    source      = "vagrant.pub"
    destination = "/tmp/vagrant.pub"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /home/vagrant/.ssh",
      "cat /tmp/vagrant.pub >> /home/vagrant/.ssh/authorized_keys",
      "chown -R vagrant:vagrant /home/vagrant/.ssh",
      "chmod 700 /home/vagrant/.ssh",
      "chmod 600 /home/vagrant/.ssh/authorized_keys"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      output = "artifacts/ubuntu${var.version}.vagrant.box"
    }
  }
}