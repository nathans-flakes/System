# Contains general user environment configuration
{ config, pkgs, unstable, ... }:
{
  # Disable mutable users, force everything to go through the flake
  users.mutableUsers = false;

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

  # Enable fish as a login shell
  environment.shells = [ pkgs.bashInteractive unstable.fish ];
  users.users.nathan = {
    isNormalUser = true;
    home = "/home/nathan";
    description = "Nathan McCarty";
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" "libvirtd" "uinput" "adbusers" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRs6zVljIlQEZ8F+aEBqqbpeFJwCw3JdveZ8TQWfkev cardno:000615938515"
    ];
    shell = unstable.fish;
    hashedPassword = "$6$ShBAPGwzKZuB7eEv$cbb3erUqtVGFo/Vux9UwT2NkbVG9VGCxJxPiZFYL0DIc3t4GpYxjkM0M7fFnh.6V8MoSKLM/TvOtzdWbYwI58.";
  };

  # Install general use packages
  environment.systemPackages = with pkgs; [
    # Install our shell of choice
    unstable.fish
    # Install rclone
    rclone
  ];
}
