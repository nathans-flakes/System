{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.nathan.programs.util.gpg {
    programs.gpg = {
      enable = true;
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryFlavor = "qt";
      extraConfig = ''
        allow-emacs-pinentry
      '';
    };
  };
}
