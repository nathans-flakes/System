# Core development libraries
{ config, pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    # Full version of git
    unstable.gitFull
    # Git addons
    git-secret
    unstable.git-lfs
    # General development requirements
    python3Full
    cmake
    libtool
    gnumake
    nixpkgs-fmt
    # jq for interacting with JSON
    jq
    # Direnv for nix-shell niceness
    direnv
  ];
}
