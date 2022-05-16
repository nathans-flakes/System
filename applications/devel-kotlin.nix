{ config, lib, pkgs, inputs, unstable, ... }:

{
  environment.systemPackages = with unstable; [
    kotlin
    kotlin-native
    kotlin-language-server
    ktlint
  ];
}
