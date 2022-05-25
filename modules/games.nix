{ pkgs, ... }: {
  environment.systemPackages =
    let
      glfw-patched = pkgs.glfw-wayland.overrideAttrs (attrs: {
        patches = attrs.patches ++ [ ../patches/minecraft/0003-Don-t-crash-on-calls-to-focus-or-icon.patch ];
      });
    in
    with pkgs; [
      # Dwarf fortress
      (dwarf-fortress-packages.dwarf-fortress-full.override {
        enableFPS = true;
      })
      # PolyMC minecraft stuff
      polymc
      glfw-patched
    ];
}
