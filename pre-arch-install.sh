loadkeys us
timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true

sgdisk -Z /dev/vda
sgdisk -n 1::+1G --typecode=1:ef00 --change-name=1:'EFI' /dev/vda
sgdisk -n 2::-0 --typecode=2:8303 --change-name=2:'ROOT' /dev/vda

mkfs.fat -F32 /dev/vda1
mkfs.btrfs /dev/vda2
mount /dev/vda2 /mnt

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

mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@ /dev/vda2 /mnt
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@home /dev/vda2 --mkdir /mnt/home
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@opt /dev/vda2 --mkdir /mnt/opt
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@srv /dev/vda2 --mkdir /mnt/srv
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@cache /dev/vda2 --mkdir /mnt/var/cache
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@images /dev/vda2 --mkdir /mnt/var/liv/libvirt/images
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@log /dev/vda2 --mkdir /mnt/var/log
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@spool /dev/vda2 --mkdir /mnt/var/spool
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@tmp /dev/vda2 --mkdir /mnt/var/tmp
mount -o noatime,ssd,compress=zstd:3,space_cache=v2,discard=async,subvol=@docker /dev/vda2 --mkdir /mnt/var/lib/docker
mount /dev/vda1 --mkdir /mnt/efi

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --download-timeout 60 --country India,Singapore --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

pacstrap /mnt base base-devel linux linux-firmware linux-headers sudo nano btrfs-progs networkmanager network-manager-applet man-db man-pages pipewire pipewire-jack pipewire-pulse intel-ucode texinfo git grub grub-btrfs reflector efibootmgr

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt
