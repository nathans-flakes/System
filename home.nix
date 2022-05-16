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
  ## Misc packages that were in user.nix
  # Install general use packages
  environment.systemPackages = with pkgs; [
    # Install our shell of choice
    fish
    # Install rclone
    rclone
  ];
}
