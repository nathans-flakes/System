{ pkgs, lib, ... }: {

  # Define the hostname, enable dhcp
  networking = {
    hostName = "levitation";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;
  };

  # Enable programs we don't want on every machine
  programs = {
    steam.enable = true;
    adb.enable = true;
  };

  # Firewall ports
  # 61377 - SoulSeek
  # Enable firewall and pass some ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 61377 ];
    allowedUDPPorts = [ 61377 ];
  };
}
