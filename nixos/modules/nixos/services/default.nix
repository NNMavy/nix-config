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
    ./omni
    ./podman
    ./restic
    ./nginx
    ./monitoring.nix
    ./reboot-required-check.nix
  ];
}
