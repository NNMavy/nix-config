{
  imports = [
    ./adguardhome
    ./chrony
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
