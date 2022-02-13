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
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" "libvirtd" "uinput" "adbusers" ];
      hashedPassword = "$6$ShBAPGwzKZuB7eEv$cbb3erUqtVGFo/Vux9UwT2NkbVG9VGCxJxPiZFYL0DIc3t4GpYxjkM0M7fFnh.6V8MoSKLM/TvOtzdWbYwI58.";
      shell = unstable.fish;
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
