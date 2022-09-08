{ config, lib, pkgs, inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable { config = { allowUnfree = true; }; system = pkgs.system; };
  irisDesktopItem = pkgs.makeDesktopItem {
    name = "iris";
    desktopName = "Iris";
    exec = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform -ozone-platform=wayland \"--app=http://localhost:6680/iris/\"";
    terminal = false;
  };
in
{
  config = lib.mkIf config.nathan.programs.media.enable {
    # General Packages
    home.packages = with pkgs; [
      unstable.spotify
      unstable.vlc
      unstable.plex-media-player
      unstable.obs-studio
      nicotine-plus
      irisDesktopItem
      picard
    ];
    # Mopidy service
    # TODO: Add scrobbling
    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [
        mopidy-mpd
        mopidy-iris
        mopidy-scrobbler
        mopidy-local
      ];
      # extraConfigFiles = config.nathan.programs.media.mopidyExtraConfig;
      settings = {
        file = {
          media_dirs = [
            "~/Music"
          ];
        };
        local = {
          enabled = true;
          media_dir = "~/Music";
        };
        mpd = {
          enabled = true;
        };
      };
    };
  };
}
