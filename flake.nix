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
      url = "github:nix-community/home-manager";
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
          ./modules/default.nix
          ({ pkgs, lib, ... }: {
            # Configure hostname
            networking = {
              hostName = hostName;
            };
            # Setup sops
            # Add default secrets
            sops = {
              defaultSopsFile = ./secrets/nathan.yaml;
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
      nixosConfigurations = {
        levitation = makeNixosSystem {
          system = "x86_64-linux";
          hostName = "levitation";
          extraModules = [
            ./hardware/levitation.nix
            ({ pkgs, config, lib, ... }: {
              boot.loader = {
                grub = {
                  enable = true;
                  version = 2;
                  efiSupport = true;
                  # Go efi only
                  devices = [ "nodev" ];
                  # Use os-prober
                  useOSProber = true;
                };
                efi = {
                  efiSysMountPoint = "/boot/";
                  canTouchEfiVariables = false;
                };
              };
              # Setup system configuration
              nathan = {
                programs = {
                  games = true;
                };
                config = {
                  isDesktop = true;
                  nix.autoUpdate = false;
                };
              };
              # Configure networking
              networking = {
                domain = "mccarty.io";
                useDHCP = false;
                interfaces.enp6s0.useDHCP = true;
                nat.externalInterface = "enp6s0";
                # Open ports for soulseek
                # TODO add in soulseek
                firewall = {
                  allowedTCPPorts = [ 61377 ];
                  allowedUDPPorts = [ 61377 ];
                };
              };
              # FIXME borg backup module

              # Setup home manager
              home-manager.users.nathan = { config, lib, pkgs, ... }: {
                # Module configuration
                nathan = {
                  config = {
                    isDesktop = true;
                  };
                };
              };
            })
          ];
        };

        x86vm = makeNixosSystem {
          system = "x86_64-linux";
          hostName = "x86vm";
          extraModules = [
            "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
            "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
            ({ pkgs, config, lib, ... }: {
              nathan = {
                programs = {
                  games = true;
                };
                config = {
                  isDesktop = true;
                  nix.autoUpdate = false;
                };
              };
              home-manager.users.nathan = import ./home-manager/machines/x86vm.nix;

              # Workaround to get sway working in qemu
              environment.variables = {
                "WLR_RENDERER" = "pixman";
              };
            })
          ];
        };
      };
    };
}
