{ config, nixosConfig, lib, pkgs, ... }:

with lib; {
  config = mkIf config.nathan.services.email.enable {
    # Packages used for mbsync + mu + protonmail-bridge
    home.packages = with pkgs; [
      pass
      protonmail-bridge
      mu
      xapian
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
          # TODO: Move into `pass`
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
              certificatesFile = ../../certificates/protonmail-${nixosConfig.networking.hostName}.pem;
            };
          };
          smtp = {
            host = "127.0.0.1";
            port = 1025;
            tls = {
              useStartTls = true;
              certificatesFile = ../../certificates/protonmail-${nixosConfig.networking.hostName}.pem;
            };
          };
          mbsync = {
            enable = true;
            create = "maildir";
          };
          mu.enable = true;
        };
      };
    };
    # Setup mbsync
    programs.mbsync = {
      enable = true;
    };
    services.mbsync = {
      enable = true;
      postExec = "${pkgs.mu}/bin/mu index";
    };
    # Setup mu
    programs.mu = {
      enable = true;
    };
  };
}
