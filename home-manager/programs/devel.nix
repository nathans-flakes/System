{ config, lib, pkgs, inputs, ... }:
let
  devel = config.nathan.programs.devel;
  unstable = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}";
  inherit (import ../../modules/lib.nix { inherit lib; inherit pkgs; }) nLib;
in

with lib; with nLib; {
  config = mkMerge [
    # Core development utilites
    (mkIf devel.core {
      home.packages = with pkgs;
        appendIf
          pkgs.stdenv.isLinux
          # General packages
          [
            # Git addons
            git-secret
            delta
            # General development requirements
            cmake
            libtool
            gnumake
            nixpkgs-fmt
            # sops for secrets management
            sops
          ]
          # Linux specific packages
          [
            gcc
            binutils
            unstable.mold
          ];

      programs = {
        direnv = {
          enable = true;
        };
        # Neovim
        # (I'm not abonding emacs I just want the tutor)
        neovim = {
          enable = true;
        };
      };
    })
    # Rust development
    (mkIf devel.rust {
      home.packages = with pkgs; [
        # Rustup for having the compiler around
        rustup
        # Install the latest rust analyzer
        inputs.fenix.packages."${pkgs.system}".rust-analyzer
        # Misc cargo utilites
        cargo-binutils # Allow invoking the llvm tools included with the toolchain
        cargo-edit # Command line Cargo.toml manipulation
        cargo-asm # Dump the generated assembly
        cargo-fuzz # front end for fuzz testing rust
        cargo-license # Audit the licenses of dependencies
        cargo-criterion # Benchmarking front end
        cargo-audit # Check dependencies for known CVEs
        cargo-bloat # Find out what's taking up space in the executable
        cargo-udeps # Find unused dependencies
        cargo-expand # Dump expanded macros
        unstable.cargo-tarpaulin # Code coverage
        cargo-play # Quickly execute code outside of a crate
        # For building stuff that uses protocol buffers
        protobuf
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
    # Python Development
    (mkIf devel.python {
      home.packages = with pkgs; [
        python3Full
        nodePackages.pyright
      ];
    })
    # JavaScript/TypeScript Development
    (mkIf devel.js {
      home.packages = with pkgs; [
        nodejs
        yarn
        nodePackages.typescript
        deno
      ];
    })
    # Raku Development
    (mkIf devel.raku {
      home.packages = with pkgs; [
        rakudo
        zef
      ];
    })
  ];
}


# TODO: Add pyright and python3Full under python module
