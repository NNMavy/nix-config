{ pkgs, ... }:

{
  podman-containers = pkgs.callPackage ./podman-containers.nix { };
  multiviewer-for-f1 = pkgs.callPackage ./multiviewer-for-f1.nix { };
  npiperelay = pkgs.callPackage ./npiperelay.nix { };
}
