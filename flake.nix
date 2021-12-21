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
        modules = [
          ./hardware/levitation.nix
          ./modules/user.nix
          ./modules/common.nix
          ./modules/audio.nix
          ./modules/sway.nix
          ./modules/fonts.nix
          ./modules/gpg.nix
          ./modules/logitech.nix
          ./modules/qemu.nix
          ./modules/docker.nix
          ./modules/ssh.nix
          ./applications/utils-core.nix
          ./applications/communications.nix
          ./applications/devel-core.nix
          ./applications/devel-rust.nix
          ./applications/emacs.nix
          ./applications/image-editing.nix
          ./applications/media.nix
          ./applications/syncthing.nix
          ({ pkgs, ... }: {
            ## Boot, drivers, and host name
            # Use grub
            boot.loader = {
              grub = {
                enable = true;
                version = 2;
                efiSupport = true;
                # Go efi only
                device = "nodev";
                # Use os-prober
                useOSProber = true;
              };
              efi = {
                efiSysMountPoint = "/boot/";
                canTouchEfiVariables = true;
              };
            };
            # Enable AMD gpu drivers early
            boot.initrd.kernelModules = [ "amdgpu" ];
            # Use the zen kernel
            boot.kernelPackages = pkgs.linuxPackages_zen;
            # Define the hostname, enable dhcp
            networking = {
              hostName = "levitation";
              domain = "mccarty.io";
              useDHCP = false;
              interfaces.enp5s0.useDHCP = true;
            };
            ## System specific configuration
            programs = {
              steam.enable = true;
              adb.enable = true;
            };
            ## Left over uncategorized packages
            environment.systemPackages = with pkgs; [
              firefox-wayland
            ];
          })
        ];
      };
    };
}
