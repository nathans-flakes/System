# Media players and other applications
{ config, pkgs, lib, unstable, ... }:
let
  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-daemon-environment";
    paths = with pkgs; [
      mopidy-mpd
      mopidy-iris
      mopidy-scrobbler
    ];
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # Spotify
    spotify
    # Latest version of vlc
    unstable.vlc
    # Plex client
    plex-media-player
    # OBS studio for screen recording
    unstable.obs-studio
    # Soulseek client
    nicotine-plus
    # Mopidy + extensions
    mopidy
  ];

  # Mount music directory
  systemd.user.services.rclone-music = {
    description = "Rclone mount ~/Music";
    serviceConfig = {
      # So we can pick up the fusermount wrapper, this is a less than ideal way to do this
      Environment = "PATH=/usr/bin:/run/wrappers/bin/";
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone mount music: /home/nathan/Music --vfs-cache-mode full --vfs-cache-max-size 32Gi --vfs-read-chunk-size 4Mi --vfs-read-ahead 8Mi --config /home/nathan/.config/rclone/rclone.conf --cache-dir /home/nathan/.cache/rclone";
    };
    enable = true;
  };

  # Start mopidy as a user service, for sanity
  systemd.user.services.mopidy = {
    description = "Mopidy music server";
    serviceConfig = {
      ExecStart = "${mopidyEnv}/bin/mopidy";
    };
    wants = [ "rclone-music.service" ];
    enable = true;
  };
  # Same for the scanning service
  systemd.user.services.mopidy-scan = {
    description = "Mopidy files local scanner";
    serviceConfig = {
      ExecStart = "${mopidyEnv}/bin/mopidy local scan";
      Type = "oneshot";
    };
    wants = [ "rclone-music.service" ];
  };

}
