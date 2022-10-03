{ config, lib, pkgs, inputs, ... }:

{
  # Setup hardware
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  # Sops setup for this machine
  sops.secrets = {
    "borg-ssh-key" = {
      sopsFile = ../../secrets/tounge/borg.yaml;
      format = "yaml";
    };
    "borg-password" = {
      sopsFile = ../../secrets/tounge/borg.yaml;
      format = "yaml";
    };
    "cloudflare-api" = {
      sopsFile = ../../secrets/tounge/cloudflare-api;
      format = "binary";
    };
  };
  # Setup system configuration
  nathan = {
    services = {
      nginx = {
        enable = true;
        acme = true;
      };
      matrix = {
        enable = true;
        baseDomain = "community.rs";
        enableRegistration = true;
      };
      borg = {
        enable = true;
        extraExcludes = [
          "/var/lib/docker"
          "/var/log"
        ];
        passwordFile = config.sops.secrets."borg-password".path;
        sshKey = config.sops.secrets."borg-ssh-key".path;
      };
    };
    config = {
      setupGrub = false;
      nix = {
        autoUpdate = true;
        autoGC = true;
      };
      harden = false;
      virtualization = {
        docker = true;
      };
    };
  };
  # Configure networking
  networking = {
    domain = "mccarty.io";
    useDHCP = false;
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "10.0.0.10";
        prefixLength = 21;
      }];
    };

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    # Open ports in firewall
    firewall = {
      allowedTCPPorts = [ 3080 30443 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  # Setup home manager
  home-manager.users.nathan = import ./home.nix;

  # Setup pi hole
  virtualisation.oci-containers.containers."pihole" = {
    image = "pihole/pihole:latest";
    ports = [
      "10.0.0.10:53:53/tcp"
      "10.0.0.10:53:53/udp"
      "172.23.98.121:53:53/tcp"
      "172.23.98.121:53:53/udp"
      "3080:80"
      "30443:443"
    ];
    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
    ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--dns=1.1.1.1"
    ];
    workdir = "/var/lib/pihole/";
  };

  # Nginx virtual hosts
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "pihole.mccarty.io" = {
        forceSSL = true;
        useACMEHost = "mccarty.io";
        locations."/" = {
          proxyPass = "http://localhost:3080";
          extraConfig = ''
            allow 172.23.0.0/16;
            deny all;
          '';
        };
      };
      "hub.mccarty.io" = {
        forceSSL = true;
        useACMEHost = "mccarty.io";
        locations."/" = {
          proxyPass = "http://localhost:3081";
          extraConfig = ''
            allow 172.23.0.0/16;
            deny all;
          '';
        };
      };
      "sonarr.mccarty.io" = {
        forceSSL = true;
        useACMEHost = "mccarty.io";
        locations."/" = {
          proxyPass = "http://10.0.3.10:8989";
          extraConfig = ''
            allow 172.23.0.0/16;
            deny all;
          '';
        };
      };
      "radarr.mccarty.io" = {
        forceSSL = true;
        useACMEHost = "mccarty.io";
        locations."/" = {
          proxyPass = "http://10.0.3.10:7878";
          extraConfig = ''
            allow 172.23.0.0/16;
            deny all;
          '';
        };
      };
      "sabnzbd.mccarty.io" = {
        forceSSL = true;
        useACMEHost = "mccarty.io";
        locations."/" = {
          proxyPass = "http://10.0.3.10:8080";
          extraConfig = ''
            allow 172.23.0.0/16;
            deny all;
          '';
        };
      };

    };
  };
  # Now we can configure ACME so we can get a star cert
  security.acme.certs."mccarty.io" = {
    domain = "*.mccarty.io";
    group = "nginx";
    extraDomainNames = [ "mccarty.io" ];
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets."cloudflare-api".path;
    dnsPropagationCheck = true;
  };
}
