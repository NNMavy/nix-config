{
  inputs,
  pkgs ? import <nixpkgs> {},
}: {
  npiperelay = pkgs.callPackage ./npiperelay.nix {};
  tesla-auth = pkgs.callPackage ./tesla-auth.nix {};
  talosctl = pkgs.callPackage ./talosctl.nix {};
  talhelper = pkgs.callPackage inputs.talhelper {};
}
