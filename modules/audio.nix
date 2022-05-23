## Setup pipewire, including bluetooth audio
{ config, pkgs, unstable, ... }:
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
    # Turn on the media session manager, and setup bluetooth
    media-session = {
      enable = true;
      # Configure bluetooth support
      config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "a2dp_sink" ];
              # SBC-XQ is not expected to work on all headset + adapter combinations.
              "bluez5.sbc-xq-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };
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
