{ config, nixosConfig, lib, pkgs, ... }:

with lib; {
  config = mkIf config.nathan.services.email.enable {
    # Packages used for mbsync + mu + protonmail-bridge
    home.packages = with pkgs; [
      pass
      protonmail-bridge
      mu
    ];
    # Configure protonmail as a service
    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Proton Mail Bridge";
        After = [ "graphical-session-pre.target" ];
        Before = [ "mbsync.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive
        '';
      };
    };
    # Setup accounts
    accounts.email = {
      maildirBasePath = ".mail";
      accounts = {
        "nathan@mccarty.io" = {
          maildir = {
            path = "nathan@mccarty.io";
          };
          address = "nathan@mccarty.io";
          primary = true;
          realName = "Nathan McCarty";
          userName = "nathan@mccarty.io";
          passwordCommand = "${pkgs.pass}/bin/pass protonmail-bridge-password";
          aliases = [
            "thatonelutenist@protonmail.com"
            "nathan@asuran.rs"
            "nathan@community.rs"
          ];
          imap = {
            host = "127.0.0.1";
            port = 1143;
            tls = {
              useStartTls = true;
              certificatesFile = ../../../certificates/protonmail-${nixosConfig.networking.hostName}.pem;
            };
          };
          smtp = {
            host = "127.0.0.1";
            port = 1025;
            tls = {
              useStartTls = true;
              certificatesFile = ../../../certificates/protonmail-${nixosConfig.networking.hostName}.pem;
            };
          };
          mbsync = {
            enable = true;
            create = "maildir";
            remove = "both";
          };
          mu.enable = true;
          msmtp = {
            enable = true;
          };
        };
      };
    };
    ## Enable email applications
    # Setup mbsync for incoming emails
    # For fun reasons this requires enabling the program and the service
    programs.mbsync = {
      enable = true;
    };
    services.mbsync = {
      enable = true;
      frequency = "*:0/1";
      # Index manually with mu if we don't have emacs setup, but if we have the emacs service setup,
      # run through emacsclient, as it will have the lock
      postExec =
        if config.nathan.programs.emacs.service
        then
          "${../../../scripts/update-mu4e.sh}"
        else
          "${pkgs.mu}/bin/mu index";
    };
    # Setup mu for indexing emails
    programs.mu = {
      enable = true;
    };
    # Setup msmtp for outbound emails
    programs.msmtp = {
      enable = true;
    };
  };
}
