{ config, lib, pkgs, ... }:

{
  nathan = {
    services = {
      email = {
        enable = true;
      };
    };
    config = {
      isDesktop = true;
    };
  };

  # # Sway outputs
  # wayland.windowManager.sway.config = {
  #   output = {
  #     DP-1 = {
  #       pos = "0 140";
  #       scale = "1";
  #       subpixel = "rgb";
  #     };
  #     DP-3 = {
  #       pos = "2560 0";
  #       scale = "1.25";
  #       subpixel = "rgb";
  #     };
  #     HDMI-A-1 = {
  #       pos = "5632 140";
  #       scale = "1";
  #       subpixel = "rgb";
  #     };
  #   };
  #   startup = [
  #     # GLPaper
  #     { command = "glpaper DP-1 ${../../custom-files/sway/selen.frag} --fork"; }
  #     { command = "glpaper DP-3 ${../../custom-files/sway/selen.frag} --fork"; }
  #     { command = "glpaper HDMI-A-1 ${../../custom-files/sway/selen.frag} --fork"; }
  #   ];
  # };
  # # Mako output configuration
  # programs.mako = {
  #   # Lock mako notifs to main display
  #   output = "DP-3";
  # };
}
