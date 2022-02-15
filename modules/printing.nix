{ config, pkgs, unstable, ... }:
{
  services.printing = {
    enable = true;
    drivers = [
      # My printer requires at least v5 to run, 21.11 has 3.70
      unstable.canon-cups-ufr2
    ];
  };
}
