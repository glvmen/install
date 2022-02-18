#!/bin/bash

pacman -Sy --noconfirm dialog || { echo "Error at script start: Are you sure you're running this as the root user? Are you sure you have an internet connection?"; exit; }

hostname=$(dialog --no-cancel --inputbox "Enter a name for the computer." 10 60 3>&1 1>&2 2>&3 3>&1)

timezone=$(tzselect)

timedatectl set-ntp true

diskname=$(dialog --no-cancel --inputbox "Enter the path for target disk." 10 60 3>&1 1>&2 2>&3 3>&1)
boot="${diskname}1"
root="${diskname}2"

fdisk $diskname

# partprobe

mkfs.fat -F 32 $boot
mkfs.exfat $root
mount $root /mnt
mkdir -p /mnt/boot
mount $boot /mnt/boot

pacman -Sy --noconfirm archlinux-keyring

pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab

echo "$hostname" >> /mnt/etc/hostname

dialog --defaultno --title "Final Qs" --yesno "Want to stop the setup with a basic system?"  5 30 && reboot


## Chroot ##

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime

hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf

localectl --no-convert set-x11-keymap de pc105 neo_quertz
