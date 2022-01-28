{ pkgs, unstable, ... }: {
  environment.systemPackages = with unstable; [
    # Dwarf fortress
    (dwarf-fortress-packages.dwarf-fortress-full.override {
      enableFPS = true;
    })
  ];
}
