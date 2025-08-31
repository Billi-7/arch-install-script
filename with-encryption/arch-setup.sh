#!/usr/bin/env bash

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "LAB" >> /etc/hostname
echo "127.0.1.1       LAB" >> /etc/hosts

echo "set the root password"
passwd
useradd -m -g users -G wheel Billi
echo "set the user password"
passwd Billi
echo "Billi ALL=(ALL) ALL" >> /etc/sudoers.d/Billi

sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
sed -i '55s/filesystem/encrypt filesystem/' /etc/mkinitcpio.conf
mkinitcpio -p linux

sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ cryptdevice=UUID=your_encrypted_partition_uuid:cryptroot root=/dev/mapper/cryptroot"/' /etc/default/grub
sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/your_encrypted_partition_uuid/$(blkid -s UUID -o value /dev/vda2)/" /etc/default/grub
sudo sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub

grub-install --target=x86_64-efi  --boot-directory=/efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /efi/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable fstrim.timer
