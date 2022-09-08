{ config, lib, pkgs, ... }:
let
  nc = config.nathan.config;
in
with lib;
{
  config = mkMerge [
    (mkIf nc.virtualization.qemu
      {
        # Enable the kernel modules
        boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
        # Enable libvirt
        virtualisation.libvirtd.enable = true;
        # Install virt-manager
        environment.systemPackages = with pkgs; [
          virtmanager
        ];
      })
    (mkIf nc.virtualization.docker {
      # Enable docker
      virtualisation.docker = {
        enable = true;
        # Automatically prune to keep things lean
        autoPrune.enable = true;
      };
      # Make sure our containers can reach the network
      boot.kernel.sysctl."net.ipv4.ip_forward" = true;
    })
    (mkIf nc.virtualization.lxc {
      virtualisation.lxd = {
        enable = true;
        recommendedSysctlSettings = true;
      };
      users.users.${nc.user} = mkIf nc.installUser {
        extraGroups = [ "lxd" ];
      };
    })
    (mkIf nc.virtualization.nixos {
      # Setup networking for nixos containers
      networking = {
        nat = {
          enable = true;
          internalInterfaces = [ "ve-+" ];
        };
      };
    })
  ];
}
