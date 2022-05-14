# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/26b08694-708a-447d-be16-abc3fc2b0d70";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/882E-B495";
      fsType = "vfat";
    };

  fileSystems."/var" =
    {
      device = "/dev/disk/by-uuid/26b08694-708a-447d-be16-abc3fc2b0d70";
      fsType = "btrfs";
      options = [ "subvol=var" ];
    };

  fileSystems."/etc" =
    {
      device = "/dev/disk/by-uuid/26b08694-708a-447d-be16-abc3fc2b0d70";
      fsType = "btrfs";
      options = [ "subvol=etc" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/26b08694-708a-447d-be16-abc3fc2b0d70";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/26b08694-708a-447d-be16-abc3fc2b0d70";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2c823521-9ab0-44bb-9f40-3963757cf4b5"; }];

}
