{ config, pkgs, unstable, ... }:
{
  imports = [ "$unstable/nixos/modules/services/printing/cupsd.nix" ];
  disabledModules = [ "services/printing/cupsd.nix" ];
  services.printing = {
    enable = true;
    drivers = [
      # My printer requires at least v5 to run, 21.11 has 3.70
      unstable.canon-cups-ufr2
    ];
  };

  environment.systemPackages = [
    unstable.canon-cups-ufr2
  ];
}
