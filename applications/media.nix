# Media players and other applications
{ config, pkgs, lib, unstable, ... }:
let
  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-daemon-environment";
    paths = with pkgs; [
      mopidy-mpd
      mopidy-iris
      mopidy-scrobbler
      mopidy-local
    ];
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };
  mopidyConf = pkgs.writeText "mopidy.conf"
    ''
      [core]
      #cache_dir = $XDG_CACHE_DIR/mopidy
      #config_dir = $XDG_CONFIG_DIR/mopidy
      #data_dir = $XDG_DATA_DIR/mopidy
      #max_tracklist_length = 10000
      #restore_state = false

      [logging]
      #verbosity = 0
      #format = %(levelname)-8s %(asctime)s [%(process)d:%(threadName)s] %(name)s\n  %(message)s
      #color = true
      #config_file =

      [audio]
      #mixer = software
      #mixer_volume = 
      #output = autoaudiosink
      #buffer_time = 

      [proxy]
      #scheme = 
      #hostname = 
      #port = 
      #username = 
      #password = 

      [file]
      enabled = true
      media_dirs =
       ~/Music
      #  $XDG_MUSIC_DIR|Music
      #excluded_file_extensions = 
      #  .directory
      #  .html
      #  .jpeg
      #  .jpg
      #  .log
      #  .nfo
      #  .pdf
      #  .png
      #  .txt
      #  .zip
      #show_dotfiles = false
      #follow_symlinks = false
      #metadata_timeout = 1000

      [local]
      media_dir = /home/nathan/Music

      [http]
      #enabled = true
      #hostname = 127.0.0.1
      #port = 6680
      #zeroconf = Mopidy HTTP server on $hostname
      #allowed_origins = 
      #csrf_protection = true
      #default_app = mopidy

      [m3u]
      #enabled = true
      #base_dir = $XDG_MUSIC_DIR
      #default_encoding = latin-1
      #default_extension = .m3u8
      #playlists_dir =

      [softwaremixer]
      #enabled = true

      [stream]
      #enabled = true
      #protocols = 
      #  http
      #  https
      #  mms
      #  rtmp
      #  rtmps
      #  rtsp
      #metadata_blacklist = 
      #timeout = 5000

      [mpd]
      enabled = true
    '';
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
    mopidy-mpd
    mopidy-iris
    mopidy-scrobbler
    mopidy-local
    # Picard for sorting
    unstable.picard
  ];

  # Start mopidy as a user service, for sanity
  systemd.user.services.mopidy = {
    description = "Mopidy music server";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${mopidyEnv}/bin/mopidy --config ${lib.concatStringsSep ":" [mopidyConf config.sops.secrets.lastfm-conf.path]}";
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
