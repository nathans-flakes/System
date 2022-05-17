{ config, lib, pkgs, unstable, fenix, ... }:

{
  system.stateVersion = "21.11";

  environment.sessionVariables = {
    XDG_RUNTIME_DIR = "/data/data/com.termux.nix/files/home/run";
    GDK_DPI_SCALE = "2";
    GDK_SCALE = "2";
  };

  # Get home-manager up and running
  home-manager.config = ./home-manager/common.nix;

  # Have to put packages here, as it does not have environment.systemPackages
  environment.packages = with pkgs;
    [
      ###
      ## utils-core
      ###
      # Basic command line utilities
      wget
      tmux
      nano
      unzip
      any-nix-shell
      htop
      # Spell check
      hunspell
      hunspellDicts.en-us
      # Rust rewrites of common shell utilities
      unstable.starship
      exa
      bat
      fd
      sd
      du-dust
      ripgrep
      ripgrep-all
      tokei
      hyperfine
      unstable.bottom
      dogdns
      duf
      # CLI Markdown renderer
      glow
      # Command line file manager
      broot
      # Much better curl
      unstable.httpie
      # CLI spreadsheets
      visidata
      # User friendly cut
      choose
      # Cheatsheet manager
      cheat
      # Ping with a graph
      gping
      # Man but terse
      tealdeer
      # Pandoc for documentation
      unstable.pandoc
      # For nslookup
      dnsutils
      # Feh image viewer
      feh
      # Mosh for better high-latency ssh
      mosh
      ###
      ## devel-core
      ###
      # Full version of git
      unstable.gitFull
      # Git addons
      git-secret
      unstable.git-lfs
      delta
      # General development requirements
      python3Full
      cmake
      libtool
      gnumake
      nixpkgs-fmt
      # jq for interacting with JSON
      jq
      jc
      # Viewer for deeply nested JSON
      fx
      # Direnv for nix-shell niceness
      direnv
      ###
      ## devel-rust
      ###
      # Use rustup to get the compiler
      rustup
      # Install the latest rust analyzer
      fenix.rust-analyzer
      # Sccache for faster builds
      sccache
      # Misc cargo utilites
      cargo-binutils # Allow invoking the llvm tools included with the toolchain
      cargo-edit # Command line Cargo.toml manipulation
      cargo-asm # Dump the generated assembly
      cargo-fuzz # front end for fuzz testing rust
      cargo-license # Audit the licenses of dependencies
      cargo-criterion # Benchmarking front end
      cargo-audit # Check dependencies for known CVEs
      cargo-bloat # Find out what's taking up space in the executable
      cargo-udeps # Find unused dependencies
      cargo-expand # Dump expanded macros
      unstable.cargo-tarpaulin # Code coverage
      cargo-play # Quickly execute code outside of a crate
      # For building stuff that uses protocol buffers
      protobuf
    ];
}
