{ pkgs, ... }:

{
  cockpit-podman = pkgs.callPackage ./cockpit-podman.nix { };
  flux-local = pkgs.python3Packages.callPackage ./flux-local.nix {};
  npiperelay = pkgs.callPackage ./npiperelay.nix { };
}
