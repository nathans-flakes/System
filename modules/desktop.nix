{ config, lib, pkgs, ... }:
let
  nc = config.nathan.config;
in
with lib; {
  # Generic desktop configuration
  config = mkMerge [
    (mkIf nc.isDesktop
      {
        # Ergodox
        environment.systemPackages = with pkgs; [
          wally-cli
        ];
        hardware.keyboard.zsa.enable = true;
        # Configure grub if configured
      })
    (mkIf nc.setupGrub {
      ## Boot, drivers, and host name
      # Use grub
      boot.loader = {
        grub = {
          enable = true;
          version = 2;
          efiSupport = true;
          # Go efi only
          devices = [ "nodev" ];
          # Use os-prober
          useOSProber = true;
        };
        efi = {
          efiSysMountPoint = "/boot/";
          canTouchEfiVariables = false;
        };
      };
      # Configure audio
    })
    (mkIf nc.audio {
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
      environment.systemPackages = with pkgs;[
        pulseaudio
        pavucontrol
        noisetorch
      ];
      # Add noisetorch for microphone noise canceling
      programs.noisetorch = {
        enable = true; # TODO: https://github.com/noisetorch/NoiseTorch/releases/tag/0.11.6
      };
      # Configure fonts
    })
    (mkIf nc.fonts {
      fonts.fonts = with pkgs; [
        ## Monospace Fonts
        # FiraCode with nerd-fonts patch, as well as fira-code symbols for emacs
        (nerdfonts.override { fonts = [ "FiraCode" ]; })
        fira-code-symbols
        fira
        # Proportional
        roboto
        liberation_ttf
        noto-fonts
      ];
    })
  ];
}
