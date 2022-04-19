{ pkgs, lib, ... }: {

  # Define the hostname, enable dhcp
  networking = {
    hostName = "levitation";
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;
  };

  # Enable programs we don't want on every machine
  programs = {
    steam.enable = true;
    adb.enable = true;
  };

  # Firewall ports
  # 61377 - SoulSeek
  # Enable firewall and pass some ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 61377 ];
    allowedUDPPorts = [ 61377 ];
  };

  ## Machine specific home-manager
  home-manager.users.nathan = {
    # Sway outputs
    wayland.windowManager.sway.config = {
      output = {
        DP-1 = {
          pos = "0 140";
          scale = "1";
          subpixel = "rgb";
        };
        DP-3 = {
          pos = "2560 0";
          scale = "1.25";
          subpixel = "rgb";
        };
        HDMI-A-1 = {
          pos = "5632 140";
          scale = "1";
          subpixel = "rgb";
        };
      };
      startup = [
        # GLPaper
        { command = "glpaper DP-1 ${../custom-files/sway/selen.frag} --fork"; }
        { command = "glpaper DP-3 ${../custom-files/sway/selen.frag} --fork"; }
        { command = "glpaper HDMI-A-1 ${../custom-files/sway/selen.frag} --fork"; }
      ];
    };
    # Mako output configuration
    programs.mako = {
      # Lock mako notifs to main display
      output = "DP-3";
    };
  };
}
