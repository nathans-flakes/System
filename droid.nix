{ config, lib, pkgs, ... }:

{
  system.stateVersion = "21.11";
  user = {
    userName = "nathan";
  };
  environment.sessionVariables = {
    XDG_RUNTIME_DIR = "/data/data/com.termux.nix/files/home/run";
    GDK_DPI_SCALE = "2";
    GDK_SCALE = "2";
  };
}
