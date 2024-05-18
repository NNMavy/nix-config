{
  inputs,
  pkgs ? import <nixpkgs> {},
}: {
  npiperelay = pkgs.callPackage ./npiperelay.nix {};
  tesla-auth = pkgs.callPackage ./tesla-auth.nix {};
  talhelper = pkgs.callPackage inputs.talhelper {};
}
