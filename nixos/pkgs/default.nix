{ pkgs, ... }:

{
  podman-containers = pkgs.callPackage ./podman-containers.nix { };
  npiperelay = pkgs.callPackage ./npiperelay.nix { };
}
