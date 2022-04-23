{ config, pkgs, ... }:
{
  fonts.fonts = with pkgs; [
    ## Monospace Fonts
    # FiraCode with nerd-fonts patch, as well as fira-code symbols for emacs
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code-symbols
    fira
    # Proportional
    roboto
    liberation_ttf
    noto-fonts
  ];
}
