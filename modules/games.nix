{ pkgs, nixpkgs-unstable, ... }: {
  environment.systemPackages =
    let
      # https://github.com/Admicos/minecraft-wayland
      glfw-patched = pkgs.glfw-wayland.overrideAttrs (attrs: {
        patches = attrs.patches ++ [
          ../patches/minecraft/0003-Don-t-crash-on-calls-to-focus-or-icon.patch
          ../patches/minecraft/0004-wayland-fix-broken-opengl-screenshots-on-mutter.patch
        ];
      });
      stable-packages = with pkgs; [
        # Dwarf fortress
        (dwarf-fortress-packages.dwarf-fortress-full.override {
          enableFPS = true;
        })
        # PolyMC minecraft stuff
        polymc
        glfw-patched
      ];
      unstable-packages = with nixpkgs-unstable.legacyPackages."${pkgs.system}"; [
        # Packwiz for maintaing modpacks
        packwiz
      ];
    in
    stable-packages ++ unstable-packages;
}
