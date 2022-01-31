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
}
