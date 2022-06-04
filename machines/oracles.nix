{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Configure networking
  networking = {
    hostName = "oracles";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp1s0f1.ipv4.addresses = [{
      address = "104.238.220.96";
      prefixLength = 24;
    }];
    defaultGateway = "104.238.220.1";
    nameservers = [ "172.23.98.121" "1.1.1.1" ];
  };

  # Open ports in firewall
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 ];
  networking.firewall.enable = true;
  # Trust zerotier interface
  networking.firewall.trustedInterfaces = [ "zt5u4uutwm" ];

  # Add nginx and acme certs
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
  security.acme = {
    defaults.email = "nathan@mccarty.io";
    acceptTerms = true;
  };
  # Redis
  services.redis.servers.main = {
    enable = true;
    bind = "172.23.108.12";
  };

  # Install java
  environment.systemPackages = with pkgs; [
    jdk
  ];
}
