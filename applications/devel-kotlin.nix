{ config, lib, pkgs, java, unstable, ... }:

{
  environment.systemPackages = with unstable; [
    java.packages.${system}.semeru-stable
    gradle
    kotlin
    kotlin-native
    kotlin-language-server
    ktlint
  ];
}
