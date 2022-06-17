{ config, lib, pkgs, ... }:

{

  options.nathans-home.bat = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = lib.mkIf config.nathans-home.bat.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "zenburn";
        style = "header,rule,snip,changes";
      };
    };
  };
}
