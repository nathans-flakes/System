## Setup pipewire, including bluetooth audio
{ config, pkgs, ... }:
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
  #programs.noisetorch = {
  # enable = true; TODO: https://github.com/noisetorch/NoiseTorch/releases/tag/0.11.6
  # Use latest noisetorch, its a fast moving target
  #package = unstable.noisetorch;
  #};
}
