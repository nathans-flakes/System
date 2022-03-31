{ pkgs, config, unstable, ... }:
{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  ## Linux specific user configuration
  users = {
    mutableUsers = false;
    isNormalUser = true;
    users.nathan = {
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" "libvirtd" "uinput" "adbusers" "plugdev" ];
      hashedPassword = "$6$ShBAPGwzKZuB7eEv$cbb3erUqtVGFo/Vux9UwT2NkbVG9VGCxJxPiZFYL0DIc3t4GpYxjkM0M7fFnh.6V8MoSKLM/TvOtzdWbYwI58.";
      openssh.authorizedKeys.keys = [
        # yubikey ssh key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRs6zVljIlQEZ8F+aEBqqbpeFJwCw3JdveZ8TQWfkev cardno:000615938515"
        # Macbook pro key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBfkO7kq37RQMT8UE8zQt/vP4Ub7kizLw6niToJwAIe nathan@Nathans-MacBook-Pro.local"
      ];
    };
  };
  # enable sudo
  security.sudo.enable = true;
  home-manager = {
    users.nathan = {
      # Alacritty configuration
      programs.alacritty = {
        enable = true;
        settings = {
          env = {
            TERM = "xterm-256color";
            ALACRITTY = "1";
          };
          font = {
            normal.family = "FiraCode Nerd Font";
            bold.family = "FiraCode Nerd Font";
            italic.family = "FiraCode Nerd Font";
            bold_italic.family = "FiraCode Nerd Font";
            size = 9.0;
          };
          colors = {
            primary = {
              background = "0x103c48";
              foreground = "0xadbcbc";
            };
            normal = {
              black = "0x184956";
              red = "0xfa5750";
              green = "0x75b938";
              yellow = "0xdbb32d";
              blue = "0x4695f7";
              magenta = "0xf275be";
              cyan = "0x41c7b9";
              white = "0x72898f";
            };
            bright = {
              black = "0x2d5b69";
              red = "0xff665c";
              green = "0x84c747";
              yellow = "0xebc13d";
              blue = "0x58a3ff";
              magenta = "0xff84cd";
              cyan = "0x53d6c7";
              white = "0xcad8d9";
            };
          };
        };
      };
      ## Multimedia
      # Easyeffects for the eq
      services.easyeffects.enable = true;
    }
      }
      }
