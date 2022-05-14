{ config, pkgs, lib, ... }:
{
  # Setup gitea
  services.gitea = {
    enable = true;
    appName = "Nathan's Git";
    database = {
      type = "sqlite3";
    };
    domain = "git.mccarty.io";
    rootUrl = "https://git.mccarty.io";
    httpPort = 3001;
    settings = {
      ui = {
        DEFAULT_THEME = "arc-green";
      };
      service = {
        DISABLE_REGISTRATION = lib.mkForce true;
      };
      repository = {
        DEFAULT_BRANCH = "main";
      };
    };
    lfs.enable = true;
  };
  # Setup the docker networking for woodpecker
  systemd.services.init-woodpecker-network-and-files = {
    description = "Create the network bridge woodpecker-br for filerun.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-woodpecker-server" ];

    serviceConfig.Type = "oneshot";
    script =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in
      ''
         # Put a true at the end to prevent getting non-zero return code, which will
         # crash the whole service.
         check=$(${dockercli} network ls | grep "woodpecker-br" || true)
         if [ -z "$check" ]; then
           ${dockercli} network create woodpecker-br
        else
          echo "woodpecker-br already exists in docker"
        fi
      '';
  };
  # Setup woodpecker
  virtualisation.oci-containers.containers = {
    woodpecker-server = {
      image = "woodpeckerci/woodpecker-server:latest";
      ports = [ "8000:8000" ];
      volumes = [ "woodpecker-server-data:/var/lib/drone" ];
      environment = {
        WOODPECKER_OPEN = "true";
        WOODPECKER_GITEA = "true";
        WOODPECKER_HOST = "https://ci.mccarty.io";
        WOODPECKER_GITEA_URL = "https://git.mccarty.io";
        WOODPECKER_LIMIT_CPU_QUOTA = "400000";
        WOODPECKER_LIMIT_MEM = "2147483648";
      };
      environmentFiles = [ "/var/lib/secret/woodpecker-server" ];
      extraOptions = [ "--network=woodpecker-br" ];
    };
    woodpecker-agent = {
      image = "woodpeckerci/woodpecker-agent:latest";
      dependsOn = [ "woodpecker-server" ];
      volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      environment = {
        WOODPECKER_SERVER = "woodpecker-server:9000";
        WOODPECKER_MAX_PROCS = "2";
      };
      environmentFiles = [ "/var/lib/secret/woodpecker-agent" ];
      extraOptions = [ "--network=woodpecker-br" ];
    };
  };


  services.nginx = {
    virtualHosts."git.mccarty.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3001";
    };
    virtualHosts."ci.mccarty.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8000";
    };
  };
}
