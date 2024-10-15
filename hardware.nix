{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Kernel modules related to hardware
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  # Filesystem setup (matches your pre-existing partition layout)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f89c2fdc-a718-4a49-86bd-c4d976f62eec";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f89c2fdc-a718-4a49-86bd-c4d976f62eec";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/f89c2fdc-a718-4a49-86bd-c4d976f62eec";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/f89c2fdc-a718-4a49-86bd-c4d976f62eec";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/f89c2fdc-a718-4a49-86bd-c4d976f62eec";
    fsType = "btrfs";
    options = [
      "subvol=@snapshots"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };

  # Swap devices
  swapDevices = [
    { device = "/dev/disk/by-uuid/30a3677f-5d04-41f2-bf5a-e9ec0043c932"; }
    { device = "/dev/disk/by-uuid/0a2d4577-cfb6-4a54-b779-7c18ee805409"; }
  ];

  # CPU microcode for AMD processors
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
