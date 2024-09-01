#!/usr/bin/env bash

# Unmount any mounted filesystems on the disks
echo "Unmounting filesystems..."
umount /mnt/.snapshots
umount /mnt/var/log
umount /mnt/nix
umount /mnt/home
umount /mnt

# Turn off swap on both disks
echo "Turning off swap..."
swapoff /dev/nvme0n1p2
swapoff /dev/nvme1n1p2

# Wipe the partition table from both disks
echo "Wiping partition tables..."
sgdisk --zap-all /dev/nvme0n1
sgdisk --zap-all /dev/nvme1n1

# Remove any directories within /mnt
echo "Cleaning up /mnt directory..."
rm -rf /mnt/*

# Verify the wipe
echo "Verifying the wipe..."
lsblk -f

echo "Disks have been wiped and /mnt has been cleaned up. Ready for new partitions."
