{ config, lib, pkgs, inputs, ... }:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}";
in
{
  config = lib.mkIf config.nathan.programs.image-editing {
    home.packages = with pkgs; [
      # RawTherapee for raw editing
      unstable.rawtherapee
      # Gimp for complex editing
      unstable.gimp-with-plugins
      # Krita for drawing
      unstable.krita
      # Pinta for basic image editing
      unstable.pinta
      # Command line tools for image conversion and handling
      imagemagickBig
    ];
  };
}
