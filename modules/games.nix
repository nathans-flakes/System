{ pkgs, unstable, ... }: {
  environment.systemPackages =
    let
      glfw-patched = unstable.glfw-wayland.overrideAttrs (attrs: {
        patches = attrs.patches ++ [ ../patches/minecraft/0003-Don-t-crash-on-calls-to-focus-or-icon.patch ];
      });
    in
    with unstable; [
      # Dwarf fortress
      (pkgs.dwarf-fortress-packages.dwarf-fortress-full.override {
        enableFPS = true;
      })
      # PolyMC minecraft stuff
      polymc
      glfw-patched
    ];
}
