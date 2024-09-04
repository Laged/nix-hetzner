
#!/usr/bin/env bash

# Set the disk variables
disk_one="/dev/nvme0n1"
disk_two="/dev/nvme1n1"

# 1. Partitioning the disks
echo "Creating new MBR partition tables..."
parted $disk_one --script -- mklabel msdos
parted $disk_two --script -- mklabel msdos

echo "Creating partitions on both disks..."
# Create root partition (align to MiB for better performance)
parted $disk_one --script -- mkpart primary 1MiB -8GB
parted $disk_two --script -- mkpart primary 1MiB -8GB

# Create swap partition (last 8GB of the disk)
parted $disk_one --script -- mkpart primary linux-swap -8GB 100%
parted $disk_two --script -- mkpart primary linux-swap -8GB 100%

# Set the boot flag on the root partition
parted $disk_one --script -- set 1 boot on
parted $disk_two --script -- set 1 boot on

echo "Waiting for the system to recognize the new partitions..."
partprobe $disk_one
partprobe $disk_two
lsblk -l

# 2. Formatting the partitions
echo "Creating Btrfs RAID1 filesystem on the root partitions..."
mkfs.btrfs -f -L nixos_raid1 -m raid1 -d raid1 ${disk_one}p1 ${disk_two}p1

echo "Creating swap partitions..."
mkswap -L swap ${disk_one}p2
mkswap -L swap ${disk_two}p2
swapon ${disk_one}p2
swapon ${disk_two}p2

# 3. Setting up Btrfs subvolumes
echo "Ensuring /mnt directory exists..."
mkdir -p /mnt
mount ${disk_one}p1 /mnt

echo "Creating necessary Btrfs subvolumes..."
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots

echo "Unmounting the filesystem..."
umount /mnt

# 4. Remounting subvolumes
echo "Creating directories for subvolumes..."
mkdir -p /mnt/home /mnt/nix /mnt/var/log /mnt/.snapshots

echo "Remounting Btrfs subvolumes..."
mount -o noatime,compress=zstd,subvol=@ ${disk_one}p1 /mnt
mount -o noatime,compress=zstd,subvol=@home ${disk_one}p1 /mnt/home
mount -o noatime,compress=zstd,subvol=@nix ${disk_one}p1 /mnt/nix
mount -o noatime,compress=zstd,subvol=@log ${disk_one}p1 /mnt/var/log
mount -o noatime,compress=zstd,subvol=@snapshots ${disk_one}p1 /mnt/.snapshots

# 5. Verification
echo "Verifying mounted subvolumes..."
lsblk -f
btrfs filesystem df /mnt
btrfs filesystem show

echo "Filesystem setup complete."
