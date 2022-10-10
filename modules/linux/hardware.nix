{ config, lib, pkgs, ... }:
let
  nw = config.nathan.hardware;
in
with lib;
{
  config = mkMerge [
    {
      hardware.logitech.wireless = mkIf nw.logitech {
        enable = true;
        enableGraphical = true;
      };
    }
    (mkIf nw.amdPassthrough {
      # Turn on IOMMU and the needed drivers
      boot = {
        kernelParams = [ "amd_iommu=on" ];
        kernelModules = [ "kvm-amd" "vifo-pci" ];
      };
      # Enable libvirtd
      virtualisation.libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";
        qemu = {
          ovmf = {
            enable = true;
            package = pkgs.OVMFFull;
            runAsRoot = true;
          };
          swtpm.enable = true;
        };
      };

    })
  ];
}
