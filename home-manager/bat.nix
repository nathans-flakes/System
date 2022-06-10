{ config, lib, pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
      style = "header,rule,snip,changes";
    };
  };
}
