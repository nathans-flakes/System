{ config, lib, pkgs, ... }:

{
  nathan = {
    services = {
      email = {
        # TODO: enable
        enable = false;
      };
    };
    programs = {
      util = {
        productivity = true;
      };
      devel = {
        core = true;
        rust = true;
        jvm = true;
        python = true;
        js = true;
        raku = true;
      };
      emacs = {
        enable = true;
        # TODO: enable
        service = false;
      };
    };
  };
}
