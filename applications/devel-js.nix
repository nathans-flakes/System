{ config, unstable, pkgs, ... }:

{
  environment.systemPackages = with unstable; [
    nodejs
    yarn
    nodePackages.typescript
    deno
  ];
}
