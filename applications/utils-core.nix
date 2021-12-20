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
    unstable.starship
    exa
    bat
    fd
    sd
    du-dust
    ripgrep
    tokei
    unstable.procs
    hyperfine
    unstable.bottom
    # Pandoc for documentation
    unstable.pandoc
    # For nslookup
    dnsutils
    # Feh image viewer
    feh
  ];
}
