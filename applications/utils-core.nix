# Basic, must have, command-line utilities
{ config, pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    # Basic command line utilities
    wget
    tmux
    nano
    unzip
    any-nix-shell
    htop
    # Spell check
    hunspell
    hunspellDicts.en-us
    # Rust rewrites of common shell utilities
    starship
    exa
    bat
    fd
    sd
    du-dust
    ripgrep
    ripgrep-all
    tokei
    hyperfine
    unstable.bottom
    dogdns
    unstable.zenith
    duf
    # CLI Markdown renderer
    glow
    # Command line file manager
    broot
    # Much better curl
    httpie
    # CLI spreadsheets
    visidata
    # User friendly cut
    choose
    # Cheatsheet manager
    cheat
    # Ping with a graph
    gping
    # Man but terse
    tealdeer
    # Pandoc for documentation
    unstable.pandoc
    # For nslookup
    dnsutils
    # Feh image viewer
    feh
    # Mosh for better high-latency ssh
    mosh
    # PV for viewing pipes
    pv
  ];
}
