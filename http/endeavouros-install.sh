#!/usr/bin/env bash
set -euxo pipefail

DISK="/dev/vda"
HOSTNAME="endeavouros"
VAGRANT_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

timedatectl set-ntp true

sgdisk --zap-all "${DISK}"
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:EFI "${DISK}"
sgdisk -n 2:0:0 -t 2:8300 -c 2:ROOT "${DISK}"
partprobe "${DISK}"
sleep 2

mkfs.fat -F32 "${DISK}1"
mkfs.ext4 -F "${DISK}2"

mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

pacman -Sy --noconfirm archlinux-keyring endeavouros-keyring || pacman -Sy --noconfirm archlinux-keyring
pacstrap -K /mnt \
  base \
  linux \
  linux-firmware \
  grub \
  efibootmgr \
  networkmanager \
  openssh \
  sudo \
  qemu-guest-agent

genfstab -U /mnt >> /mnt/etc/fstab
echo "${HOSTNAME}" > /mnt/etc/hostname

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=us" > /mnt/etc/vconsole.conf

arch-chroot /mnt useradd -m -G wheel -s /bin/bash vagrant
echo "root:vagrant" | arch-chroot /mnt chpasswd
echo "vagrant:vagrant" | arch-chroot /mnt chpasswd
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /mnt/etc/sudoers.d/vagrant
chmod 440 /mnt/etc/sudoers.d/vagrant

install -d -m 700 -o 1000 -g 1000 /mnt/home/vagrant/.ssh
echo "${VAGRANT_PUBLIC_KEY}" > /mnt/home/vagrant/.ssh/authorized_keys
chmod 600 /mnt/home/vagrant/.ssh/authorized_keys
arch-chroot /mnt chown -R vagrant:vagrant /home/vagrant/.ssh

arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl enable qemu-guest-agent

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=EndeavourOS --removable
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

umount -R /mnt
reboot
