{ config, pkgs, unstable, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: {
    canon-cups-ufr2 = unstable.canon-cups-ufr2;
  };
  
  services.printing = {
    enable = true;
    drivers = [
      pkgs.canon-cups-ufr2
    ];
  };

  environment.systemPackages = with pkgs; [
    canon-cups-ufr2
    cups
  ];
}
