{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ../../common/programs/emacs.nix ];

  config = lib.mkIf config.nathan.programs.emacs.enable {
    # Setup service
    services.emacs = {
      enable = config.nathan.programs.emacs.service;
      client.enable = true;
      defaultEditor = true;
    };
  };
}
