{
  description = "Nathan's system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
    };
    mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, fenix, emacs, mozilla, sops-nix, home-manager, darwin }:
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
        })
      ];
      coreModules = baseModules ++ [
        ./modules/common.nix
        ./modules/ssh.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        ## Setup sops
        ({ pkgs, config, ... }: {
          # Add default secrets
          sops.defaultSopsFile = ./secrets/nathan.yaml;
          # Use system ssh key as an age key
          sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          # Load up lastfm scrobbling secret 
          sops.secrets.lastfm-conf = {
            owner = "nathan";
            format = "binary";
            sopsFile = ./secrets/lastfm.conf;
          };
        })
        ## Setup home manager
        ./home.nix
      ];
      desktopModules = coreModules ++ [
        ./modules/audio.nix
        ./modules/sway.nix
        ./modules/fonts.nix
        ./modules/gpg.nix
        ./modules/logitech.nix
        ./modules/qemu.nix
        ./modules/docker.nix
        ./modules/printing.nix
        ./applications/communications.nix
        ./applications/devel-core.nix
        ./applications/devel-core-linux.nix
        ./applications/devel-rust.nix
        ./applications/emacs.nix
        ./applications/image-editing.nix
        ./applications/media.nix
        ./applications/syncthing.nix
        ./desktop.nix
      ];
      mozillaOverlay = import "${mozilla}";
    in
    {
      nixosConfigurations = {
        levitation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ emacs.overlay mozillaOverlay ];
              system = "x86_64-linux";
            };
            fenix = fenix.packages.x86_64-linux;
          };
          modules = [
            ./hardware/levitation.nix
            ./machines/levitation.nix
            ./modules/games.nix
            ./home-linux.nix
          ] ++ desktopModules;
        };

        x86vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ emacs.overlay ];
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
              overlays = [ emacs.overlay ];
              system = "x86_64-darwin";
            };
            fenix = fenix.packages.x86_64-darwin;
          };
          modules = baseModules ++ [
            ./darwin-modules/base.nix
            home-manager.darwinModules.home-manager
            ./home.nix
            ./darwin-modules/gpg.nix
            ./applications/devel-core.nix
            ./applications/devel-rust.nix
          ];
        };
      };
    };
}
