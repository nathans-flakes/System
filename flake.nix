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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, fenix, emacs, mozilla }:
    let
      coreModules = [
        ./modules/user.nix
        ./modules/common.nix
        ./modules/ssh.nix
        ./applications/utils-core.nix
        ({ pkgs, ... }: {
          ## Setup binary caches
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
          };
        })
      ];
      desktopModules = coreModules ++ [
        ./modules/audio.nix
        ./modules/sway.nix
        ./modules/fonts.nix
        ./modules/gpg.nix
        ./modules/logitech.nix
        ./modules/qemu.nix
        ./modules/docker.nix
        ./applications/communications.nix
        ./applications/devel-core.nix
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
      nixosConfigurations.levitation = nixpkgs.lib.nixosSystem {
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
          ./modules/games.nix
        ] ++ desktopModules;
      };

      nixosConfigurations.x86vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          unstable = import nixpkgs-unstable {
            config = { allowUnfree = true; };
            overlays = [ emacs.overlay ];
            system = "x86_64-linux";
          };
          fenix = fenix.packages.x86_64-linux;
        };
        modules = desktopModules;
      };
    };
}
