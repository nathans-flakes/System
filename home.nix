{ pkgs, config, unstable, ... }:
{
  ## Some general settings that were in the user configuration
  # Set time zone
  time.timeZone = "America/New_York";
  ## Setup user first
  users = {
    users.nathan = {
      # darwin is special
      home = if pkgs.stdenv.isDarwin then "/Users/nathan" else "/home/nathan";
      description = "Nathan McCarty";
      shell = pkgs.fish;
    };
  };
  ## Home manager proper
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Disable git "safe directories" for root
    # This is _highly_ cautioned against, but the feature breaks my workflow
    users.root = {
      programs.git = {
        extraConfig = {
          safe = {
            directory = "*";
          };
        };
      };
    };
    users.nathan = {
      programs.home-manager.enable = true;
      ## Shell
      # Shell proper
      programs.fish = {
        enable = true;
        # Setup our aliases
        shellAliases = {
          ls = "exa --icons";
          la = "exa --icons -a";
          lg = "exa --icons --git";
          cat = "bat";
          dig = "dog";
          df = "duf";
        };
        # Custom configuration
        interactiveShellInit = ''
          # Setup any-nix-shell
          any-nix-shell fish --info-right | source
          # Load logger function
          source ~/.config/fish/functions/cmdlogger.fish
        '';
        functions = {
          # Setup command logging to ~/.logs
          cmdlogger = {
            onEvent = "fish_preexec";
            body = ''
              mkdir -p ~/.logs
              echo (date -u +"%Y-%m-%dT%H:%M:%SZ")" "(echo %self)" "(pwd)": "$argv >> ~/.logs/(hostname)-(date "+%Y-%m-%d").log
            '';
          };
        };
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
        delta.enable = true;
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
          # Disable annoying safe directory nonsense
          safe = {
            directory = "*";
          };
        };
      };
      # SSH configuration
      programs.ssh = {
        enable = true;
        # extra config to set the ciphers
        extraConfig = ''
          Ciphers aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
        '';
        # enable session reuse
        controlMaster = "auto";
        controlPersist = "10m";
        # Configure known hosts
        matchBlocks = {
          "levitation" = {
            forwardAgent = true;
            user = "nathan";
            hostname = "172.23.12.134";
          };
          "perception" = {
            forwardAgent = true;
            user = "nathan";
            hostname = "172.23.55.145";
          };
        };
      };
    };
  };
  ## Misc packages that were in user.nix
  # Install general use packages
  environment.systemPackages = with pkgs; [
    # Install our shell of choice
    fish
    # Install rclone
    rclone
  ];
}
