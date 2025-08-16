#!/usr/bin/env bash
loadkeys us
timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true

sgdisk -Z /dev/vda
sgdisk -n 1::+1G --typecode=1:ef00 --change-name=1:'EFI' /dev/vda
sgdisk -n 2::-0 --typecode=2:8309 --change-name=2:'ROOT' /dev/vda

cryptsetup --sector-size 4096 --verbose luksFormat /dev/vda2
echo"enter the passphrase for crypt partition"
cryptsetup open /dev/vda2 cryptroot
echo"enter the passphrase to open crypt partition"
mkfs.fat -F32 /dev/vda1
mkfs.btrfs /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

cd /mnt
if ! btrfs subvolume list /mnt | grep -q '@'; then
    btrfs subvolume create @
fi
if ! btrfs subvolume list /mnt | grep -q '@home'; then
    btrfs subvolume create @home
fi
if ! btrfs subvolume list /mnt | grep -q '@opt'; then
    btrfs subvolume create @opt
fi
if ! btrfs subvolume list /mnt | grep -q '@srv'; then
    btrfs subvolume create @srv
fi
if ! btrfs subvolume list /mnt | grep -q '@cache'; then
    btrfs subvolume create @cache
fi
if ! btrfs subvolume list /mnt | grep -q '@images'; then
    btrfs subvolume create @images
fi
if ! btrfs subvolume list /mnt | grep -q '@log'; then
    btrfs subvolume create @log
fi
if ! btrfs subvolume list /mnt | grep -q '@spool'; then
    btrfs subvolume create @spool
fi
if ! btrfs subvolume list /mnt | grep -q '@tmp'; then
    btrfs subvolume create @tmp
fi
if ! btrfs subvolume list /mnt | grep -q '@docker'; then
    btrfs subvolume create @docker
fi

cd ~
umount -R /mnt

mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot --mkdir /mnt/home
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@opt /dev/mapper/cryptroot --mkdir /mnt/opt
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@srv /dev/mapper/cryptroot --mkdir /mnt/srv
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@cache /dev/mapper/cryptroot --mkdir /mnt/var/cache
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@images /dev/mapper/cryptroot --mkdir /mnt/var/liv/libvirt/images
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@log /dev/mapper/cryptroot --mkdir /mnt/var/log
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@spool /dev/mapper/cryptroot --mkdir /mnt/var/spool
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@tmp /dev/mapper/cryptroot --mkdir /mnt/var/tmp
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@docker /dev/mapper/cryptroot --mkdir /mnt/var/lib/docker
mount /dev/vda1 --mkdir /mnt/efi

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --download-timeout 60 --country India,Singapore --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

pacstrap /mnt base base-devel linux linux-firmware linux-headers sudo nano btrfs-progs networkmanager network-manager-applet man-db man-pages texinfo git grub grub-btrfs reflector efibootmgr

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt
