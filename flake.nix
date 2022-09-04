{
  description = "Nathan's system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpgks.follows = "nixpkgs";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymc = {
      url = "github:PolyMC/PolyMC";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs";
    };
    java = {
      url = "github:nathans-flakes/java";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quilt-server = {
      url = "github:forward-progress/quilt-server-nix-container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gamescope = {
      url = "github:nathans-flakes/gamescope";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , fenix
    , emacs
    , mozilla
    , sops-nix
    , home-manager
    , darwin
    , polymc
    , nix-doom-emacs
    , java
    , quilt-server
    , nixos-generators
    , wsl
    , gamescope
    , nix-on-droid
    }@inputs:
    let
      makeNixosSystem = { system, hostName, extraModules ? [ ], ourNixpkgs ? nixpkgs }: ourNixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inputs = inputs;
        };
        modules = [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          ./modules/linux/default.nix
          ({ pkgs, lib, config, ... }: {
            # Configure hostname
            networking = {
              hostName = hostName;
            };
            # Setup sops
            # Add default secrets
            sops = {
              age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            };
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnfreePredicate = (pkg: true);
            # Home manager configuration
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = {
                inputs = inputs;
                nixosConfig = config;
              };
              sharedModules = [
                ./home-manager/default.nix
              ];
            };
          })
        ] ++ extraModules;
      };
    in
    rec {
      # Real systems
      nixosConfigurations = {
        levitation = makeNixosSystem {
          system = "x86_64-linux";
          hostName = "levitation";
          extraModules = [
            ./hardware/levitation.nix
            ./machines/levitation/configuration.nix
          ];
        };

        oracles = makeNixosSystem {
          system = "x86_64-linux";
          hostName = "oracles";
          extraModules = [
            ./hardware/oracles.nix
            ./machines/oracles/configuration.nix
          ];
        };

        x86vm = makeNixosSystem {
          system = "x86_64-linux";
          hostName = "x86vm";
          extraModules = [
            "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
            "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
            ./machines/x86vm/configuration.nix
          ];
        };

        # WSL sytem
        wsl = makeNixosSystem {
          system = "x86_64-linux";
          hostName = "wsl";
          extraModules = [
            wsl.nixosModules.wsl
            ./machines/wsl/configuration.nix
          ];
        };
      };
      # Android systems
      nixOnDroidConfigurations = {
        tablet = nix-on-droid.lib.nixOnDroidConfiguration {
          config = ./machines/tablet/configuration.nix;
          system = "aarch64-linux";
        };
      };
      packages = {
        x86_64-linux = {
          # Hyper-V image
          hyperv = nixos-generators.nixosGenerate {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./machines/hyperv/configuration.nix
            ];
            format = "hyperv";
          };
        };
      };
    };
}
