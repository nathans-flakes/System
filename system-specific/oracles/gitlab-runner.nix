{ config, pkgs, lib, ... }:
{
  # setup sops for secrets
  sops.secrets."nix-asuran" = {
    format = "yaml";
    sopsFile = ../../secrets/gitlab-runner.yaml;
  };
  # Make sure docker containers can reach the network
  boot.kernel.sysctl."net.ipv4.ip_forward" = true; # 1
  # Make sure docker is enabled
  virtualisation.docker.enable = true;
  # Enable binfmt-misc so we can run aarch64 containers
  boot.binfmt.emulatedSystems = [ "wasm32-wasi" "aarch64-linux" ];
  services.gitlab-runner =
    let
      nix-shared = with lib; {
        dockerImage = "alpine";
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
          "/var/lib/secret/cache:/var/lib/secret/cache"
        ];
        dockerDisableCache = true;
        preBuildScript = pkgs.writeScript "setup-container" ''
          mkdir -p -m 0755 /nix/var/log/nix/drvs
          mkdir -p -m 0755 /nix/var/nix/gcroots
          mkdir -p -m 0755 /nix/var/nix/profiles
          mkdir -p -m 0755 /nix/var/nix/temproots
          mkdir -p -m 0755 /nix/var/nix/userpool
          mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
          mkdir -p -m 1777 /nix/var/nix/profiles/per-user
          mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
          mkdir -p -m 0700 "$HOME/.nix-defexpr"
          . ${pkgs.nix}/etc/profile.d/nix.sh
          ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-21.05 nixpkgs # 3
          ${pkgs.nix}/bin/nix-channel --update nixpkgs
          ${pkgs.nix}/bin/nix-env -i ${concatStringsSep " " (with pkgs; [ nixUnstable cacert git openssh ])}
        '';
        environmentVariables = {
          ENV = "/etc/profile";
          USER = "root";
          NIX_REMOTE = "daemon";
          PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
          NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
        };
      };
    in
    {
      enable = true;
      concurrent = 4;
      checkInterval = 1;
      services = {
        # default-asuran = {
        #   registrationConfigFile = "/var/lib/secret/gitlab-runner/asuran-default";
        #   dockerImage = "debian:stable";
        #   dockerVolumes = [
        #     "/var/run/docker.sock:/var/run/docker.sock"
        #   ];
        #   dockerPrivileged = true;
        #   tagList = [ "linux-own" ];
        # };

        nix-asuran = nix-shared // {
          registrationConfigFile = config.sops.secrets.nix-asuran.path;
          tagList = [ "nix" ];
          requestConcurrency = 8;
          limit = 4;
          runUntagged = true;
        };
      };
    };
}
