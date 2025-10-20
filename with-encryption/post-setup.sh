#!/usr/bin/env bash

pacman -Sy

sudo pacman -S hyprland kitty wofi snapper snap-pac pipewire pipewire-jack pipewire-pulse intel-ucode mlocate

sudo pacman -Syu
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -Sy
yay -S btrfs-assistant

sudo snapper -c root create-config /
sudo snapper -c home create-config /home

sudo snapper -c root set-config ALLOW_USERS="$USER" SYNCACL=yes
sudo snapper -c home set-config ALLOW_USERS="$USER" SYNCACL=yes

#sudo nano /etc/updatedb.conf (now add .snapshots in prunenames)
#sudo nano /etc/mkinitcpio.conf (now add grub-btrfs-overlayfs in hooks)
sudo mkinitcoio -p linux
sudo systemctl enable --now grub-btrfsd.service
