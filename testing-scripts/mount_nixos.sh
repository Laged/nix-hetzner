mount -o noatime,compress=zstd,subvol=@ /dev/nvme0n1p1 /mnt
mkdir -p /mnt/home /mnt/nix /mnt/var/log /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@home /dev/nvme0n1p1 /mnt/home
mount -o noatime,compress=zstd,subvol=@nix /dev/nvme0n1p1 /mnt/nix
mount -o noatime,compress=zstd,subvol=@log /dev/nvme0n1p1 /mnt/var/log
mount -o noatime,compress=zstd,subvol=@snapshots /dev/nvme0n1p1 /mnt/.snapshots

