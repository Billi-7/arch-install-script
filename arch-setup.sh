ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "earth" >> /etc/hostname
echo "127.0.1.1       earth" >> /etc/hosts
echo "set the root password"
passwd
useradd -m -g users -G wheel billi
echo "set the user password"
passwd billi
echo "billi ALL=(ALL) ALL" >> /etc/sudoers.d/billi
sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
mkinitcpio -p linux
grub-install --target=x86_64-efi  --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable fstrim.timer
