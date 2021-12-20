{ config, pkgs, unstable, ... }:
{
  # Install emacs
  environment.systemPackages = with pkgs; [
    unstable.emacsPgtkGcc
  ];
}
