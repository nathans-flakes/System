# Configure gpg with yubikey support
{ config, pkgs, ... }:
{
  # Setup environment for gpg agent
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  environment.sessionVariables = {
    SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };

  programs = {
    # Disable ssh-agent, the gpg-agent will fill in
    ssh.startAgent = false;
    # Enable gpg-agent with ssh support
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
    };
  };

  # Enable ykpersonalize to work
  services.udev.packages = [ pkgs.yubikey-personalization ];
  # Enable smartcard service
  services.pcscd.enable = true;

  # install gnupg and yubikey personalization
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
  ];
}
