{
  description = "Nathan's system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, fenix, emacs }:
    let
      coreModules = [
        ./modules/user.nix
        ./modules/common.nix
        ./modules/ssh.nix
        ./applications/utils-core.nix
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
    in
    {
      nixosConfigurations.levitation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          unstable = import nixpkgs-unstable {
            config = { allowUnfree = true; };
            overlays = [ emacs.overlay ];
            system = "x86_64-linux";
          };
          fenix = fenix.packages.x86_64-linux;
        };
        modules = [ ./hardware/levitation.nix ] ++ desktopModules;
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
