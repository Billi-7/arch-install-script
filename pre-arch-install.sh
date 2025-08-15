loadkeys us
timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true

#add some partitioning commands of sgdisk
sgdisk -n 1::+1G --typecode=1:ef00 --change-name=1:'EFI' /dev/vda
sgdisk -n 2::-0 --typecode=2:8303 --change-name=2:'ROOT' /dev/vda

mkfs.fat -F32 /dev/vda1
mkfs.btrfs /dev/vda2
mount /dev/vda2 /mnt

cd /mnt

btrfs subvolume create @
btrfs subvolume create @opt
btrfs subvolume create @srv
btrfs subvolume create @cache
btrfs subvolume create @images
btrfs subvolume create @log
btrfs subvolume create @spool
btrfs subvolume create @tmp
btrfs subvolume create @docker

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
mount /dev/your_efi_partition --mkdir /mnt/efi

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --download-timeout 60 --country India,Singapore --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

pacstrap /mnt base base-devel linux linux-firmware linux-headers sudo nano btrfs-progs networkmanager network-manager-applet man-db man-pages pipewire pipewire-jack pipewire-pulse intel-ucode texinfo git grub grub-btrfs reflector efibootmgr

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt
