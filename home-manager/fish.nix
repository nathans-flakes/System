{ config, lib, pkgs, ... }:

{
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
}
