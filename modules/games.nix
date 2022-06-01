{ pkgs, ... }: {
  environment.systemPackages =
    let
      # https://github.com/Admicos/minecraft-wayland
      glfw-patched = pkgs.glfw-wayland.overrideAttrs (attrs: {
        patches = attrs.patches ++ [
          ../patches/minecraft/0003-Don-t-crash-on-calls-to-focus-or-icon.patch
          ../patches/minecraft/0004-wayland-fix-broken-opengl-screenshots-on-mutter.patch
        ];
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
