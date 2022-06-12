# Communications software
{ config, pkgs, unstable, ... }:
{
  # Pull in personal overlay
  # nixpkgs.overlays = [ (import ../../overlays/personal/overlay.nix) ];

  environment.systemPackages = with pkgs;
    let
      enableWayland = drv: bin: drv.overrideAttrs (
        old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/${bin} \
            --add-flags "--enable-features=UseOzonePlatform" \
            --add-flags "--ozone-platform=wayland"
          '';
        }
      );
      ## Wayland workaround chromium desktop items
      # Facebook messenger 
      fbChromeDesktopItem = pkgs.makeDesktopItem {
        name = "messenger-chrome";
        desktopName = "Messenger (chrome)";
        exec = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform -ozone-platform=wayland --app=\"https://messenger.com\"";
        terminal = false;
      };
      # Teams
      teamsItem = pkgs.makeDesktopItem {
        name = "teams-wayland";
        desktopName = "Teams (Wayland)";
        exec = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform -ozone-platform=wayland --app=\"https://teams.microsoft.com\"";
        terminal = false;
      };
      # Discord

      discordWayland = pkgs.callPackage ../packages/discord/default.nix rec {
        pname = "discord-electron";
        binaryName = "Discord";
        desktopName = "Discord (Wayland)";
        version = "0.0.18";
        src = fetchurl {
          url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          hash = "sha256-BBc4n6Q3xuBE13JS3gz/6EcwdOWW57NLp2saOlwOgMI=";
        };
        electron = pkgs.electron_13;
      };
      ## Pass wayland options to existing applications
      signalWaylandItem = pkgs.makeDesktopItem {
        name = "signal-desktop-wayland";
        desktopName = "Signal (Wayland)";
        exec = "${unstable.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform -ozone-platform=wayland";
        terminal = false;
        icon = "signal-desktop";
        type = "Application";
      };
      zulipWayland = pkgs.makeDesktopItem {
        name = "zulip-wayland";
        desktopName = "Zulip (Wayland)";
        exec = "${unstable.zulip}/bin/zulip --enable-features=UseOzonePlatform --ozone-platform=wayland";
        terminal = false;
        icon = "zulip";
        type = "Application";
      };
    in
    [
      # Discord
      discordWayland
      unstable.betterdiscordctl
      # Desktop matrix client
      (enableWayland element-desktop "element-desktop")
      # Desktop signal client
      (enableWayland signal-desktop "signal-desktop")
      # Desktop telegram client
      tdesktop
      # Desktop mastodon client
      tootle
      # zulip
      unstable.zulip
      zulipWayland
      # Zoom (for work, sadly)
      unstable.zoom-us
      # Teams (also for work)
      unstable.teams
      # chromium
      chromium
      # Wayland workaround packages
      fbChromeDesktopItem
      teamsItem
    ];


  # Work around for discord jank ugh
  nixpkgs.config.permittedInsecurePackages = [
    "electron-13.6.9"
  ];
}
