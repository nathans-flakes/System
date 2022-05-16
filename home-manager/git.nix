{ config, lib, pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Nathan McCarty";
    userEmail = "nathan@mccarty.io";
    signing = {
      key = "B7A40A5D78C08885";
      signByDefault = true;
    };
    ignores = [
      "**/*~"
      "*~"
      "*_archive"
      "/auto/"
      "auto-save-list"
      ".cask/"
      ".dir-locals.el"
      "dist/"
      "**/.DS_Store"
      "*.elc"
      "/elpa/"
      "/.emacs.desktop"
      "/.emacs.desktop.lock"
      "/eshell/history"
      "/eshell/lastdir"
      "flycheck_*.el"
      "*_flymake.*"
      "/network-security.data"
      ".org-id-locations"
      ".persp"
      ".projectile"
      "*.rel"
      "/server/"
      "tramp"
      "\\#*\\#"
    ];
    delta.enable = true;
    extraConfig = {
      init = {
        defaultBranch = "trunk";
      };
      log = {
        showSignature = true;
        abbrevCommit = true;
        follow = true;
        decorate = false;
      };
      rerere = {
        enable = true;
        autoupdate = true;
      };
      merge = {
        ff = "only";
        conflictstyle = "diff3";
      };
      push = {
        default = "simple";
        followTags = true;
      };
      pull = {
        rebase = true;
      };
      status = {
        showUntrackedFiles = "all";
      };
      transfer = {
        fsckobjects = true;
      };
      color = {
        ui = "auto";
      };
      diff = {
        mnemonicPrefix = true;
        renames = true;
        wordRegex = ".";
        submodule = "log";
      };
      credential = {
        helper = "cache";
      };
      # Disable annoying safe directory nonsense
      safe = {
        directory = "*";
      };
    };
  };
}
