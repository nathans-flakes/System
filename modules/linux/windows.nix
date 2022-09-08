{ config, lib, pkgs, ... }:

with lib;{
  config = mkIf config.nathan.config.windows.enable {
    # Enable ntfs support
    boot.supportedFilesystems = [ "ntfs" ];
    # Install dislocker for mounting bitlocker encrypted partitions
    environment.systemPackages = with pkgs; [
      dislocker
    ];

    systemd.services.mount-windows =
      let
        mount = config.nathan.config.windows.mount;
      in
      mkIf mount.enable {
        description = "Mount ${mount.device} to ${mount.mountPoint}";
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
          bash
          dislocker
        ];
        serviceConfig = {
          Type = "forking";
          ExecStart =
            "${../../scripts/windows/mount.sh} ${mount.device} ${mount.mountPoint} ${mount.keyFile}";
          ExecStop = "${../../scripts/windows/unmount.sh} ${mount.device} ${mount.mountPoint}";
        };
      };
  };
}
