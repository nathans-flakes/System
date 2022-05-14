{ config, pkgs, ... }:
{
  services.plex =
    let
      myPlexRaw = pkgs.plexRaw.overrideAttrs (x:
        let
          # see https://www.plex.tv/media-server-downloads/ for 64bit rpm
          version = "1.26.1.5798-99a4a6ac9";
          hash = "sha256-Chu4IULIvkmfMEV0LSg50i6usZJZI3UWOgCHQakbhaY=";
        in
        {
          name = "plex-${version}";
          src = pkgs.fetchurl {
            url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
            inherit hash;
          };
        }
      );
      myPlex = pkgs.plex.override (x: { plexRaw = myPlexRaw; });
    in
    {
      enable = true;
      openFirewall = true;
      dataDir = "/var/lib/plex";
      user = "nathan";
      group = "users";
      package = myPlex;
    };

  services.tautulli.enable = true;
}
