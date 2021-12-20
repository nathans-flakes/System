# Setup quem/libvirt
{ config, pkgs, ... }:
{
  # Enable the kernel modules
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  # Enable libvirt
  virtualisation.libvirtd.enable = true;
  # Install virt-manager
  environment.systemPackages = with pkgs; [
    virtmanager
  ];
}
