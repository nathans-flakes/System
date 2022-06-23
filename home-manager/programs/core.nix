{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = {
    #########################
    ## SSH Configuration
    #########################
    programs.ssh = mkIf nathan.programs.util.ssh {
      # SSH configuration
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
          hostname = "100.95.223.6";
        };
        "perception" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "100.67.146.101";
        };
        "oracles" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "100.66.15.34";
        };
        "tounge" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "172.23.98.121";
        };
        "shadowchild" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "172.23.217.149";
        };
        "matrix.community.rs" = {
          forwardAgent = true;
          user = "nathan";
          hostname = "100.113.74.107";
        };
        "de1955" = {
          user = "de1955";
          hostname = "de1955.rsync.net";
        };
      };
    };
    #########################
    ## Fish Configuration
    #########################
    programs.fish = mkIf nathan.programs.util.fish {
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
    programs.starship = mkIf nathan.programs.util.fish {
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
          time_format = "%I:l%M %p";
        };
      };
    };

    #########################
    ## Git configuration
    #########################
    programs.git = mkIf nathan.programs.util.git.enable {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Nathan McCarty";
      userEmail = "nathan@mccarty.io";
      signing = {
        key = "B7A40A5D78C08885";
        signByDefault = nathan.programs.util.git.gpgSign;
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
      lfs.enable = true;
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
  } // mkIf nathan.programs.util.json {
    #########################
    ## JSON Utilities
    #########################
    programs.jq = mkIf nathan.programs.util.json {
      enable = true;
    };
    home.packages = with pkgs; [
      jc
      fx
    ];
  };
}