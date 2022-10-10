{ config, lib, pkgs, ... }:
let
  nc = config.nathan.config;
in
with lib; {
  config = mkMerge [
    {
      users = {
        # If we install the user and the system is hardended, then disable mutable users
        mutableUsers = !(nc.installUser && nc.harden);
        # Configure our user, if enabled
        users."${nc.user}" = mkMerge [
          (mkIf nc.installUser
            {
              # Darwin is special
              home = if pkgs.stdenv.isDarwin then "/Users/nathan" else "/home/nathan";
              description = "Nathan McCarty";
              shell = pkgs.fish;
              # Linux specific configuration next
            })
          (mkIf (nc.installUser && pkgs.stdenv.isLinux) {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "audio" "docker" "libvirtd" "uinput" "adbusers" "plugdev" ];
            hashedPassword = "$6$ShBAPGwzKZuB7eEv$cbb3erUqtVGFo/Vux9UwT2NkbVG9VGCxJxPiZFYL0DIc3t4GpYxjkM0M7fFnh.6V8MoSKLM/TvOtzdWbYwI58.";
            openssh.authorizedKeys.keys = [
              # yubikey ssh key
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRs6zVljIlQEZ8F+aEBqqbpeFJwCw3JdveZ8TQWfkev cardno:000615938515"
              # Macbook pro key
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBfkO7kq37RQMT8UE8zQt/vP4Ub7kizLw6niToJwAIe nathan@Nathans-MacBook-Pro.local"
              # Phone key
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFR0zpmBCb0iEOeeI6SBwgucddNzccfQ5Zmdgib5iSmF nix-on-droid@localhost"
              # Tablet key
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKltqneJjfdLjOvnWQC2iP7hP7aTYkURPiR8LFjB7z87 nix-on-droid@localhost"
            ];
          })
        ];
      };
      # If we install the user, enable sudo
      security.sudo.enable = mkDefault nc.installUser;
      # If we isntall the user, make them trusted
      nix.settings.trusted-users =
        if nc.installUser then [
          "nathan"
        ] else [ ];
      # If we setup the user, install the shell as well
      environment.systemPackages =
        if nc.installUser then [
          pkgs.fish
        ] else [ ];
      # Configure the timezone
      time.timeZone = "America/New_York";
    }
    (mkIf config.nathan.config.hardware.amdPassthrough {
      users.users."${nc.user}".extraGroups = [ "libvirtd" ];
    })
  ];
}
