# Configure gpg with yubikey support
{ config, pkgs, ... }:
{
  # Setup environment for gpg agent
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  programs = {
    # Enable gpg-agent with ssh support
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # install gnupg and yubikey personalization
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
  ];
}
