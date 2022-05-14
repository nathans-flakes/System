{ config, lib, pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Grub configuration for linode
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.forceInstall = true;
  boot.loader.timeout = 10;
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';
  boot.kernelParams = [
    "console=ttyS0"
  ];

  networking.hostName = "matrix";
  networking.domain = "community.rs";
  networking.useDHCP = false;
  networking.interfaces.enp0s5.useDHCP = true;
  networking.enableIPv6 = false;

  # Create www-html group
  users.groups.www-html.gid = 6848;
  # Add shaurya
  users.users.shaurya = {
    isNormalUser = true;
    home = "/home/shaurya";
    description = "Shaurya";
    extraGroups = [ "www-html" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA8BwFgWGrX5is2rQV+T0dy4MUWhfpE5EzYxjgLuH1V shauryashubham1234567890@gmail.com"
    ];
    shell = pkgs.nushell;
  };
  # Add www-html for my self
  users.users.nathan = {
    extraGroups = [ "www-html" ];
  };
}
