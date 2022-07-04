{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.nix-doom-emacs.hmModule ];

  config = lib.mkIf config.nathan.programs.emacs.enable {
    # Dependencies of my emacs environment
    home.packages = with pkgs; [
      # For markdown rendering
      python39Packages.grip
      # For graph generation
      graphviz
      sqlite
      # For latex editing
      texlive.combined.scheme-medium
    ];
    # Setup doom emacs
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ../../doom.d;
      emacsPackage = config.nathan.programs.emacs.package;
      emacsPackagesOverlay = self: super: {
        org-protocol-capture-html = self.trivialBuild {
          pname = "org-protocol-capture-html";
          ename = "org-protocol-capture-html";
          version = "0.0.0";
          buildInputs = [ self.s ];
          src = pkgs.fetchFromGitHub {
            owner = "alphapapa";
            repo = "org-protocol-capture-html";
            rev = "3359ce9a2f3b48df26329adaee0c4710b1024250";
            hash = "sha256-ueEHJCS+aHYCnd4Lm3NKgqg+m921nl5XijE9ZnSRQXI=";
          };
        };
      };
      extraPackages = [ pkgs.mu ];
    };
    # Setup service
    services.emacs = {
      enable = config.nathan.programs.emacs.service;
      client.enable = true;
    };
    # Set editor
    home.sessionVariables = {
      EDITOR = "emacsclient";
      VISUAL = "emacsclient";
    };
  };
}
