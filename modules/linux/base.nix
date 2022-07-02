{ config, lib, pkgs, inputs, ... }@attrs:
with lib;
{
  config = mkMerge [
    (mkIf pkgs.stdenv.isLinux
      {
        zramSwap = mkIf config.nathan.services.zramSwap
          {
            enable = true;
            algorithm = "lz4";
            memoryPercent = 25;
          };
        nix = mkIf config.nathan.config.nix.autoGC {
          autoOptimiseStore = true;
        };
      })
    (mkIf config.nathan.config.harden (import "${inputs.nixpkgs}/nixos/modules/profiles/hardened.nix" attrs))
    (mkIf ((! config.nathan.config.harden) && config.nathan.config.isDesktop) {
      # Use the zen kernel with muqss turned on
      boot.kernelPackages =
        let
          linuxZenWMuQSS = pkgs.linuxPackagesFor (pkgs.linuxPackages_zen.kernel.override {
            structuredExtraConfig = with lib.kernel; {
              SCHED_MUQSS = yes;
            };
            ignoreConfigErrors = true;
          }
          );
        in
        linuxZenWMuQSS;
    })
    (mkIf
      (config.nathan.config.nix.autoUpdate && pkgs.stdenv.isLinux)
      {
        # Auto update daily at 2 am
        system.autoUpgrade = {
          enable = true;
          allowReboot = true;
          # Update from the flake
          flake = "github:nathans-flakes/system";
          # Attempt to update daily at 2AM
          dates = "2:00";
        };
      })
  ];
}
