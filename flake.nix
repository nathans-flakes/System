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
    quilt-server = {
      url = "github:forward-progress/quilt-server-nix-container";
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
    , quilt-server
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
              # sops for borg
              sops.secrets."borg-ssh-key" = {
                sopsFile = ./secrets/levitation/borg.yaml;
                format = "yaml";
              };
              sops.secrets."borg-password" = {
                sopsFile = ./secrets/levitation/borg.yaml;
                format = "yaml";
              };
              # Setup system configuration
              nathan = {
                programs = {
                  games = true;
                };
                services = {
                  borg = {
                    enable = true;
                    extraExcludes = [
                      "/home/${config.nathan.config.user}/Music"
                      "/var/lib/docker"
                      "/var/log"
                    ];
                    passwordFile = config.sops.secrets."borg-password".path;
                    sshKey = config.sops.secrets."borg-ssh-key".path;
                  };
                };
                config = {
                  isDesktop = true;
                  setupGrub = true;
                  nix.autoUpdate = false;
                  harden = false;
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
              home-manager.users.nathan = import ./home-manager/machines/levitation.nix;
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
