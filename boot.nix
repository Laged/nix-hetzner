{
  config, pkgs, ...
}:

{
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";  # This should point to your boot disk (check with lsblk or fdisk)
    efiSupport = false;  # Disabled because we're using BIOS boot, not UEFI
  };

  # Has to match prepartitioned fs (check lsblk -lf)
  # Expected partition layout:
  # - /dev/nvme0n1p1: Btrfs partition with subvolumes for /, /home, /nix, /var/log, /.snapshots
  # - /dev/nvme0n1p2: Swap partition
}
