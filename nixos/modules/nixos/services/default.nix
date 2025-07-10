{
  imports = [
    ./adguardhome
    ./chrony
    ./chrony-exporter
    ./cloudflared
    ./cockpit
    ./docker
    ./forgejo
    ./gps
    ./podman
    ./restic
    ./nginx
    ./monitoring.nix
    ./reboot-required-check.nix
  ];
}
