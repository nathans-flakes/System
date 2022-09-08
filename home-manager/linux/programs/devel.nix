{ config, lib, pkgs, inputs, ... }:
let
  devel = config.nathan.programs.devel;
  unstable = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}";
  inherit (import ../../../modules/lib.nix { inherit lib; inherit pkgs; }) nLib;
in

with lib; with nLib; {
  config = mkMerge [
    # Core development utilites
    (mkIf devel.core {
      home.packages = with pkgs;
        # Linux specific packages
        [
          clang
          unstable.mold
        ];
    })
    # Rust development
    (mkIf devel.rust {
      home.packages = with pkgs; [
        unstable.cargo-tarpaulin # Code coverage
      ];
    })
    # JVM Development
    (mkIf devel.jvm {
      home.packages = with unstable; [
        inputs.java.packages."${pkgs.system}".semeru-stable
        gradle
        kotlin
        kotlin-native
        kotlin-language-server
        ktlint
      ];
    })
  ];
}
