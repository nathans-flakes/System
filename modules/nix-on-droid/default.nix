{ config, lib, pkgs, ... }:
let
  inherit (import ../lib.nix { inherit lib; inherit pkgs; }) nLib;
in
{
  imports = [
    ../options.nix
  ];

  options = with lib; with nLib; { };
}
