#!/usr/bin/env bash

sudo pacman -Syu

sudo pacman -S hyprland kitty wofi snapper snap-pac pipewire pipewire-jack pipewire-pulse intel-ucode mlocate sddm

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
sudo sed -i 's|PRUNENAMES = "|PRUNENAMES = ".snapshots |g' /etc/updatedb.conf
#sudo nano /etc/mkinitcpio.conf (now add grub-btrfs-overlayfs in hooks)
sed -i '55s/fsck/fsck grub-btrfs-overlayfs/' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux
sudo systemctl enable --now grub-btrfsd.service
sudo grub-mkconfig -o /efi/grub/grub.cfg
