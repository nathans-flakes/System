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
        dockerImage = "nixpkgs/nix-flakes";
        dockerVolumes = [
          "/nix:/sharedstore"
        ];
        dockerDisableCache = true;
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
