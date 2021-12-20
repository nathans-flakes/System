# Image editing applications
{ config, pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
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
}
