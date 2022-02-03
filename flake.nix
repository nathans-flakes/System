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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, fenix, emacs, mozilla, sops-nix, home-manager }:
    let
      coreModules = [
        ./modules/common.nix
        ./modules/ssh.nix
        ./applications/utils-core.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        ## Setup binary caches
        ({ pkgs, ... }: {
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
        ({ pkgs, config, ... }:
          let
            unstable = import nixpkgs-unstable {
              config = { allowUnfree = true; };
              overlays = [ emacs.overlay mozillaOverlay ];
              system = "x86_64-linux";
            };
          in
          {
            ## Some general settings that were in the user configuration
            # Set time zone
            time.timeZone = "America/New_York";
            # Select internationalisation properties.
            i18n.defaultLocale = "en_US.UTF-8";
            console = {
              font = "Lat2-Terminus16";
              keyMap = "us";
            };
            # enable sudo
            security.sudo.enable = true;
            ## Setup user first
            users = {
              mutableUsers = false;
              users.nathan = {
                isNormalUser = true;
                home = "/home/nathan";
                description = "Nathan McCarty";
                extraGroups = [ "wheel" "networkmanager" "audio" "docker" "libvirtd" "uinput" "adbusers" ];
                hashedPassword = "$6$ShBAPGwzKZuB7eEv$cbb3erUqtVGFo/Vux9UwT2NkbVG9VGCxJxPiZFYL0DIc3t4GpYxjkM0M7fFnh.6V8MoSKLM/TvOtzdWbYwI58.";
              };
            };
            ## Home manager proper
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nathan = {
                programs.home-manager.enable = true;
                ## Shell
                # Shell proper
                programs.fish = {
                  enable = true;
                  # Use latest possible fish
                  package = unstable.fish;
                  # Setup our aliases
                  shellAliases = {
                    ls = "exa --icons";
                  };
                  # Custom configuration
                  interactiveShellInit = ''
                    # Setup any-nix-shell
                    any-nix-shell fish --info-right | source
                  '';
                };
                # Starship, for the prompt
                programs.starship = {
                  enable = true;
                  settings = {
                    directory = {
                      truncation_length = 3;
                      fish_style_pwd_dir_length = 1;
                    };
                    git_commit = {
                      commit_hash_length = 6;
                      only_detached = false;
                    };
                    package = {
                      symbol = "";
                    };
                    time = {
                      disabled = false;
                      format = "[$time]($style)";
                      time_format = "%I:%M %p";
                    };
                  };
                };
                ## Multimedia
                # Easyeffects for the eq
                services.easyeffects.enable = true;
              };
            };
            ## Misc packages that were in user.nix
            # Install general use packages
            environment.systemPackages = with pkgs; [
              # Install our shell of choice
              unstable.fish
              # Install rclone
              rclone
            ];
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
