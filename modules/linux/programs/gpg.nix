{ config, lib, pkgs, ... }:
let
  np = config.nathan.programs;
  nc = config.nathan.config;
in
with lib;
{
  config = mkIf np.gpg {
    # Enable ykpersonalize to work
    services.udev.packages = [ pkgs.yubikey-personalization ];
    # Enable smartcard service
    services.pcscd.enable = true;

    # install gnupg and yubikey personalization
    environment.systemPackages = with pkgs; [
      gnupg
      yubikey-personalization
    ];
  };
}
