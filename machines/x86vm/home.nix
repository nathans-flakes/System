{ config, lib, pkgs, ... }:

{
  nathan = {
    programs = {
      util.git.gpgSign = false;
    };
    config = {
      isDesktop = true;
    };
  };
}
