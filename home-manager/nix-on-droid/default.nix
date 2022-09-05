{ config, lib, pkgs, inputs, ... }:
let
  inherit (import ../../modules/lib.nix { inherit lib; inherit pkgs; }) nLib;
in
with lib; with nLib; {
  imports = [
    ../options.nix
    ../common/programs/core.nix
    ../common/programs/devel.nix
    ../common/programs/emacs.nix
  ];

  options = { };

  config = {
    home.stateVersion = "22.05";
    programs.home-manager.enable = true;
    nathan.programs.emacs.package = pkgs.emacs28NativeComp;
  };
}
