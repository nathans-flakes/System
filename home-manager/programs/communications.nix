{ config, lib, pkgs, inputs, ... }:

{
  config = lib.mkIf config.nathan.programs.communications.enable {
    home.packages = with pkgs;
      let
        unstable = import inputs.nixpkgs-unstable { config = { allowUnfree = true; }; inherit system; };
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
        discordWayland = pkgs.callPackage ../../packages/discord/default.nix rec {
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
        zulipWayland = pkgs.makeDesktopItem {
          name = "zulip-wayland";
          desktopName = "Zulip (Wayland)";
          exec = "${unstable.zulip}/bin/zulip --enable-features=UseOzonePlatform --ozone-platform=wayland";
          terminal = false;
          icon = "zulip";
          type = "Application";
        };
        # Facebook messenger
        fbChromeDesktopItem = pkgs.makeDesktopItem {
          name = "messenger-chrome";
          desktopName = "Messenger (chrome)";
          exec = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform -ozone-platform=wayland \"--app=https://messenger.com\"";
          terminal = false;
        };
        # Teams
        teamsItem = pkgs.makeDesktopItem {
          name = "teams-wayland";
          desktopName = "Teams (Wayland)";
          exec = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform -ozone-platform=wayland \"--app=https://teams.microsoft.com\"";
          terminal = false;
        };
      in
      [
        # Discord
        discordWayland
        betterdiscordctl
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
        (enableWayland chromium "chromium")
        # Wayland workaround packages
        fbChromeDesktopItem
        teamsItem
      ];
  };
}
