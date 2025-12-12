{
  pkgs,
  ...
}:
{
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix { };
  chrony-exporter = pkgs.callPackage ./chrony-exporter.nix { };
  cockpit-podman = pkgs.callPackage ./cockpit-podman.nix { };
  flux-local = pkgs.callPackage ./flux-local.nix { };
  gpsd-prometheus-exporter = pkgs.callPackage ./gpsd-prometheus-exporter.nix { };
  mqtt-explorer = pkgs.callPackage ./mqtt-explorer.nix { };
  npiperelay = pkgs.callPackage ./npiperelay.nix { };
  talosctl = pkgs.callPackage ./talosctl.nix { };
}
