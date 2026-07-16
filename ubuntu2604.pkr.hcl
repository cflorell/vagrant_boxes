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
  vm_name              = "ubuntu-2604-amd64"
  iso_url              = "https://releases.ubuntu.com/${var.version}/ubuntu-${var.version}-live-server-amd64.iso"
  iso_checksum         = "dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"
  memory               = 2048
  disk_image           = false
  output_directory     = "build"
  accelerator          = "kvm"
  headless             = true
  disk_size            = 51200
  disk_interface       = "virtio"
  format               = "qcow2"
  net_device           = "virtio-net"
  boot_wait            = "1s"
  boot_command         = ["e<wait><down><down><down><end> autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<F10>"]
  http_directory       = "http"
  shutdown_command     = "echo 'vagrant' | sudo -S /usr/bin/systemctl poweroff"
  shutdown_timeout     = "5m"
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "20m"
  ssh_host             = "127.0.0.1"
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
