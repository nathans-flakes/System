# Utilities for developing in rust
{ config, pkgs, unstable, fenix, ... }:
{
  environment.systemPackages = with pkgs; [
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
  ];
}
