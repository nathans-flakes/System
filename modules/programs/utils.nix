{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkIf nathan.programs.utils.core
    {
      environment.systemPackages = with pkgs; [
        # Basic command line utilities
        wget
        tmux
        nano
        unzip
        any-nix-shell
        htop
        # Rust rewrites of common shell utilities
        starship
        exa
        bat
        fd
        sd
        du-dust
        ripgrep
        ripgrep-all
        hyperfine
        bottom
        dogdns
        duf
        # User friendly cut
        choose
        # Man but terse
        tealdeer
        # For nslookup
        dnsutils
        # Mosh for better high-latency ssh
        mosh
        # PV for viewing pipes
        pv
      ];
    } // mkIf nathan.programs.utils.productivity {
    environment.systemPackages = with pkgs; [
      # Feh image viewer
      feh
      tokei
      # Spell check
      hunspell
      hunspellDicts.en-us
      # CLI Markdown renderer
      glow
      # Command line file manager
      broot
      # Much better curl
      httpie
      # CLI spreadsheets
      visidata
      # Cheatsheet manager
      cheat
      # Ping with a graph
      gping
      # Pandoc for documentation
      pandoc
    ];
  } // mkIf nathan.programs.utils.binfmt {
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
    ];
  };
}
