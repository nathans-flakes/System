{ pkgs, ... }: {
  ## Boot, drivers, and host name
  # Use grub
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      # Go efi only
      device = "nodev";
      # Use os-prober
      useOSProber = true;
    };
    efi = {
      efiSysMountPoint = "/boot/";
      canTouchEfiVariables = true;
    };
  };
  # Enable AMD gpu drivers early
  boot.initrd.kernelModules = [ "amdgpu" ];
  # Use the zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Define the hostname, enable dhcp
  networking = {
    hostName = "levitation";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;
  };
  ## System specific configuration
  programs = {
    steam.enable = true;
    adb.enable = true;
  };
  ## Left over uncategorized packages
  environment.systemPackages = with pkgs; [
    firefox-wayland
  ];
}
