## Setup pipewire, including bluetooth audio
{ config, pkgs, ... }:
let new-noisetorch = pkgs.noisetorch.overrideAttrs (old: {
  src = pkgs.fetchFromGitHub {
    owner = "noisetorch";
    repo = "NoiseTorch";
    rev = "fe3ace8cc7add2f3bd42dd767c8fc292bc2aeaad";
    fetchSubmodules = true;
    hash = "sha256-A6cX1ck47/ZIn9cnV/Ow4CxVFfOX5J0K0Q+B70jCFdQ=";
  };
  version = "0.12.0";
  meta.insecure = false;
});
in
{
  # Disable normal audio subsystem explicitly
  sound.enable = false;
  # Turn on rtkit, so that audio processes can be upgraded to real time
  security.rtkit.enable = true;
  # Turn on pipewire
  services.pipewire = {
    enable = true;
    # Turn on all the emulation layers
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };
  # Turn on bluetooth services
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
  # Add pulse audio packages, but do not enable them
  environment.systemPackages = [
    pkgs.pulseaudio
  ];
  # Add noisetorch for microphone noise canceling
  programs.noisetorch = {
    enable = true; # TODO: https://github.com/noisetorch/NoiseTorch/releases/tag/0.11.6
    # Use latest noisetorch, its a fast moving target
    package = new-noisetorch;
  };
}
