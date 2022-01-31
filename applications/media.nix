# Media players and other applications
{ config, pkgs, unstable, ... }:
{
  # imports = [ ../../sensitive/mopidy.nix ];
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
}
