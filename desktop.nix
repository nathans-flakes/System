{ pkgs, lib, unstable, ... }: {
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
  # Use the zen kernel with muqss turned on
  boot.kernelPackages =
    let
      linuxZenWMuQSS = pkgs.linuxPackagesFor (pkgs.linuxPackages_zen.kernel.override {
        structuredExtraConfig = with lib.kernel; {
          SCHED_MUQSS = yes;
        };
        ignoreConfigErrors = true;
      }
      );
    in
    linuxZenWMuQSS;
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
    unstable.firefox-beta-bin
    wally-cli
  ];

  # Enable firewall and pass some ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 61377 ];
    allowedUDPPorts = [ 61377 ];
  };
  # Enable ergodox udev rules
  hardware.keyboard.zsa.enable = true;
}
