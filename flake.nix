{
  description = "Nathan's system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-staging.url = "github:NixOS/nixpkgs/staging-next-22.05";
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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-staging
    , fenix
    , emacs
    , mozilla
    , sops-nix
    , home-manager
    , darwin
    , polymc
    , nix-doom-emacs
    }:
    let
      baseModules = [
        ./applications/utils-core.nix
        ## Setup binary caches and other common nix config
        ({ pkgs, ... }: {
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;
          # First install cachix, so we can discover new ones
          environment.systemPackages = [ pkgs.cachix ];
          # Then configure up the nix community cache
          nix = {
            binaryCaches = [
              "https://nix-community.cachix.org"
            ];
            binaryCachePublicKeys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            # Turn on flakes support (from within a flake, lamo)
            package = pkgs.nixFlakes;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
          };
          # Setup overlays
          nixpkgs.overlays = [ emacs.overlay polymc.overlay ];
          # System state version for compat
          system.stateVersion = "21.11";
        })
      ];
      sopsModules = [
        sops-nix.nixosModules.sops
        ## Setup sops
        ({ pkgs, config, ... }: {
          # Add default secrets
          sops.defaultSopsFile = ./secrets/nathan.yaml;
          # Use system ssh key as an age key
          sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        })
      ];
      coreModules = baseModules ++ sopsModules ++ [
        ./modules/common.nix
        ./modules/ssh.nix
        home-manager.nixosModules.home-manager
      ];
      setHomeManagerVersions = ({ pkgs, config, unstable, ... }: {
        home-manager.users.nathan.programs = {
          starship.package = unstable.starship;
          git.package = unstable.gitFull;
          fish.package = unstable.fish;
        };
      });
      baseHomeModules = [
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.nathan = import ./home-manager/common.nix;
          };
        }
        setHomeManagerVersions
        ./home.nix
      ];
      desktopModules = baseHomeModules ++ coreModules ++ [
        ./modules/audio.nix
        ./modules/sway.nix
        ./modules/fonts.nix
        ./modules/gpg.nix
        ./modules/logitech.nix
        ./modules/qemu.nix
        ./modules/docker.nix
        ./modules/printing.nix
        ./modules/zt.nix
        ./modules/lxc.nix
        ./applications/communications.nix
        ./applications/devel-core.nix
        ./applications/devel-core-linux.nix
        ./applications/devel-rust.nix
        ./applications/devel-raku.nix
        ./applications/devel-kotlin.nix
        ./applications/devel-js.nix
        ./applications/emacs.nix
        ./applications/image-editing.nix
        ./applications/media.nix
        ./applications/syncthing.nix
        ./desktop.nix
      ];
      serverModules = baseHomeModules ++ coreModules ++ [
        ./home-linux.nix
        ./modules/zt.nix
        ./modules/autoupdate.nix
        ./applications/devel-core.nix
        ./applications/devel-core-linux.nix
      ];
      mozillaOverlay = import "${mozilla}";
    in
    {
      nixosConfigurations = {
        levitation = nixpkgs-staging.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ mozillaOverlay ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
            doomEmacs = nix-doom-emacs.hmModule;
          };
          modules = [
            ./hardware/levitation.nix
            ./machines/levitation.nix
            ./modules/games.nix
            ./home-linux.nix
          ] ++ desktopModules;
        };

        oracles = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
          };
          modules = [
            ./hardware/oracles.nix
            ./machines/oracles.nix
            ./applications/devel-rust.nix
            ./modules/docker.nix
            ./system-specific/oracles/matrix.nix
            # ./system-specific/oracles/gitlab-runner.nix
            ./system-specific/oracles/gitea.nix
          ] ++ serverModules;
        };

        perception = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
          };
          modules = [
            ./hardware/perception.nix
            ./machines/perception.nix
            ./applications/devel-rust.nix
            ./modules/docker.nix
            ./system-specific/perception/plex.nix
          ] ++ serverModules;
        };

        shadowchild = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
          };
          modules = [
            ./hardware/shadowchild.nix
            ./machines/shadowchild.nix
            ./modules/docker.nix
          ] ++ serverModules;
        };

        matrix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
          };
          modules = [
            ./hardware/matrix.nix
            ./machines/matrix.nix
            ./modules/docker.nix
            ./system-specific/matrix/matrix.nix
            ./system-specific/matrix/gitea.nix
          ] ++ serverModules;
        };

        x86vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
          };
          modules = [ ./home-linux.nix ] ++ desktopModules;
        };
      };
      darwinConfigurations = {
        "Nathans-MacBook-Pro" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ ];
              system = "x86_64-darwin";
            };
            fenix = fenix.packages.x86_64-darwin;
            doomEmacs = nix-doom-emacs.hmModule;
          };
          modules = baseModules ++ baseHomeModules ++ [
            ./darwin-modules/base.nix
            home-manager.darwinModules.home-manager
            ./modules/fonts.nix
            ./darwin-modules/gpg.nix
            ./applications/devel-core.nix
            ./applications/devel-rust.nix
            ./applications/emacs.nix
          ];
        };
      };
      homeConfigurations.linux =
        let
          system = "x86_64-linux";
        in
        home-manager.lib.homeManagerConfiguration {
          configuration = import ./home-manager/linux.nix;
          inherit system;
          username = "nathan";
          homeDirectory = "/home/nathan";
          stateVersion = "21.11";
        };
    };
}
