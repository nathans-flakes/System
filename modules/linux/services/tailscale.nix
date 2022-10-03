{ config, lib, pkgs, ... }:
let
  nathan = config.nathan;
in
with lib;
{
  config = mkIf nathan.services.tailscale.enable {
    environment.systemPackages = with pkgs; [
      tailscale
    ];

    # Enable the service
    services.tailscale = {
      enable = true;
    };

    # Setup sops
    sops.secrets."tailscale-auth" = {
      sopsFile = ../../../secrets/all/tailscale.yaml;
      format = "yaml";
    };

    # Oneshot job to authenticate to tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2
        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi
        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets."tailscale-auth".path})
      '';
    };

    # Configure firewall for tailscale
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
