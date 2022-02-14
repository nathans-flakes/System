# Communications software
{ config, pkgs, unstable, ... }:
{
  # Pull in personal overlay
  # nixpkgs.overlays = [ (import ../../overlays/personal/overlay.nix) ];

  environment.systemPackages = with pkgs;
    let
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
      ## Pass wayland options to existing applications
      signalWaylandItem = pkgs.makeDesktopItem {
        name = "signal-desktop-wayland";
        desktopName = "Signal (Wayland)";
        exec = "${pkgs.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform -ozone-platform=wayland";
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
      discord
      unstable.betterdiscordctl
      # Use unstable element for latest features
      element-desktop-wayland
      # Desktop signal client
      signal-desktop
      signalWaylandItem
      # Desktop telegram client
      tdesktop
      # zulip
      unstable.zulip
      zulipWayland
      # chromium
      chromium
      # Wayland workaround packages
      fbChromeDesktopItem
      teamsItem
    ];
}
