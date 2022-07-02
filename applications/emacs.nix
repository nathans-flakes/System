{ config, pkgs, doomEmacs, ... }:
{
  # Install emacs
  environment.systemPackages = with pkgs; [
    # For markdown rendering
    python39Packages.grip
    # For graph generation
    graphviz
    sqlite
    # For latex editing
    texlive.combined.scheme-medium
  ];

  # Utilize home-manager
  home-manager.users.nathan = {
    # Nixify doomEmacs
    # TODO:Reenable, currently off because of ghub
    imports = [ doomEmacs ];
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ../doom.d;
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
      emacsPackage = pkgs.emacsPgtkNativeComp;
    };
    # Configure org protocol handler
    home.packages = (with pkgs; [
      (makeDesktopItem {
        name = "org-protocol";
        exec = "emacsclient %u";
        comment = "Org protocol";
        desktopName = "org-protocol";
        type = "Application";
        mimeTypes = [ "x-scheme-handler/org-protocol" ];
      })
    ]);
    # Startup service
    services.emacs = {
      enable = pkgs.stdenv.isLinux;
      client.enable = true;
      defaultEditor = true;
    };
  };
}
