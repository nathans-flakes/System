{ config, pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      canon-cups-ufr2
      carps-cups
      cnijfilter2
    ];
  };

  # Enable avahi for printer discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  environment.systemPackages = with pkgs; [
    canon-cups-ufr2
    cups
    cups-filters
  ];
}
