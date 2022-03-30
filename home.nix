{ pkgs, config, unstable, ... }:
{
  ## Some general settings that were in the user configuration
  # Set time zone
  time.timeZone = "America/New_York";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  # enable sudo
  security.sudo.enable = true;
  ## Setup user first
  users = {
    mutableUsers = false;
    users.nathan = {
      isNormalUser = true;
      home = "/home/nathan";
      description = "Nathan McCarty";
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" "libvirtd" "uinput" "adbusers" "plugdev" ];
      hashedPassword = "$6$ShBAPGwzKZuB7eEv$cbb3erUqtVGFo/Vux9UwT2NkbVG9VGCxJxPiZFYL0DIc3t4GpYxjkM0M7fFnh.6V8MoSKLM/TvOtzdWbYwI58.";
      shell = unstable.fish;
      openssh.authorizedKeys.keys = [
        # yubikey ssh key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRs6zVljIlQEZ8F+aEBqqbpeFJwCw3JdveZ8TQWfkev cardno:000615938515"
        # Macbook pro key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBfkO7kq37RQMT8UE8zQt/vP4Ub7kizLw6niToJwAIe nathan@Nathans-MacBook-Pro.local"
      ];
    };
  };
  ## Home manager proper
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nathan = {
      programs.home-manager.enable = true;
      ## Shell
      # Shell proper
      programs.fish = {
        enable = true;
        # Use latest possible fish
        package = unstable.fish;
        # Setup our aliases
        shellAliases = {
          ls = "exa --icons";
        };
        # Custom configuration
        interactiveShellInit = ''
          # Setup any-nix-shell
          any-nix-shell fish --info-right | source
        '';
      };
      # Starship, for the prompt
      programs.starship = {
        enable = true;
        settings = {
          directory = {
            truncation_length = 3;
            fish_style_pwd_dir_length = 1;
          };
          git_commit = {
            commit_hash_length = 6;
            only_detached = false;
          };
          package = {
            symbol = "";
          };
          time = {
            disabled = false;
            format = "[$time]($style)";
            time_format = "%I:%M %p";
          };
        };
      };
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
      # Git configuration
      programs.git = {
        enable = true;
        userName = "Nathan McCarty";
        userEmail = "nathan@mccarty.io";
        signing = {
          key = "B7A40A5D78C08885";
          signByDefault = true;
        };
        ignores = [
          "**/*~"
          "*~"
          "*_archive"
          "/auto/"
          "auto-save-list"
          ".cask/"
          ".dir-locals.el"
          "dist/"
          "**/.DS_Store"
          "*.elc"
          "/elpa/"
          "/.emacs.desktop"
          "/.emacs.desktop.lock"
          "/eshell/history"
          "/eshell/lastdir"
          "flycheck_*.el"
          "*_flymake.*"
          "/network-security.data"
          ".org-id-locations"
          ".persp"
          ".projectile"
          "*.rel"
          "/server/"
          "tramp"
          "\\#*\\#"
        ];
        extraConfig = {
          init = {
            defaultBranch = "trunk";
          };
          log = {
            showSignature = true;
            abbrevCommit = true;
            follow = true;
            decorate = false;
          };
          rerere = {
            enable = true;
            autoupdate = true;
          };
          merge = {
            ff = "only";
            conflictstyle = "diff3";
          };
          push = {
            default = "simple";
            followTags = true;
          };
          pull = {
            rebase = true;
          };
          status = {
            showUntrackedFiles = "all";
          };
          transfer = {
            fsckobjects = true;
          };
          color = {
            ui = "auto";
          };
          diff = {
            mnemonicPrefix = true;
            renames = true;
            wordRegex = ".";
            submodule = "log";
          };
          credential = {
            helper = "cache";
          };
        };
      };
      ## Multimedia
      # Easyeffects for the eq
      services.easyeffects.enable = true;
    };
  };
  ## Misc packages that were in user.nix
  # Install general use packages
  environment.systemPackages = with pkgs; [
    # Install our shell of choice
    unstable.fish
    # Install rclone
    rclone
  ];
}
