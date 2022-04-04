{ pkgs, config, unstable, ... }:
{
  ## Some general settings that were in the user configuration
  # Set time zone
  time.timeZone = "America/New_York";
  ## Setup user first
  users = {
    users.nathan = {
      home = "/home/nathan";
      description = "Nathan McCarty";
      shell = pkgs.fish;
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
        # Setup our aliases
        shellAliases = {
          ls = "exa --icons";
          cat = "bat";
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
