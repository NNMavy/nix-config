{ pkgs, ... }:

{
  cockpit-podman = pkgs.callPackage ./cockpit-podman.nix { };
  flux-local = pkgs.python3Packages.callPackage ./flux-local.nix { };
  multiviewer-for-f1 = pkgs.callPackage ./multiviewer-for-f1.nix { };
  npiperelay = pkgs.callPackage ./npiperelay.nix { };
  atlas-probe = pkgs.callPackage ./atlas-probe.nix { };
}
