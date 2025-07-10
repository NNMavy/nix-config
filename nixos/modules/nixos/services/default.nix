{
  imports = [
    ./adguardhome
    ./chrony
    ./chrony-exporter
    ./cloudflared
    ./cockpit
    ./docker
    ./forgejo
    ./github-runner
    ./gps
    ./podman
    ./restic
    ./nginx
    ./monitoring.nix
    ./reboot-required-check.nix
  ];
}
