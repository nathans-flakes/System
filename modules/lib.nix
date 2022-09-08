{ lib, pkgs }:

{
  nLib = {
    # mkEnableOption, but defaults to true
    mkEnableOptionT = name: lib.mkOption {
      default = true;
      example = false;
      description = "Whether to enable ${name}.";
      type = lib.types.bool;
    };
    # mkEnableOption, but with a default
    mkDefaultOption = name: default: lib.mkOption {
      default = default;
      example = false;
      description = "Whether to enable ${name}.";
      type = lib.types.bool;
    };
    # Returns an empty list if the current system is not linux
    ifLinux = value: if pkgs.stdenv.isLinux then value else [ ];
    # Appends if the predicate is true
    appendIf = predicate: input: append:
      if predicate then input ++ append else input;
  };
}
