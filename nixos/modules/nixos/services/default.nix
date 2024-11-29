{
  imports = [
    ./adguardhome
    ./chrony
    ./chrony-exporter
    ./cloudflared
    ./cockpit
    ./forgejo
    ./gps
    ./klipper
    ./podman
    ./restic
    ./nginx
    ./monitoring.nix
    ./reboot-required-check.nix
  ];
}
