{
  imports = [
    ./monitoring.nix
    ./reboot-required-check.nix
    ./cloudflared
    ./cockpit
    ./forgejo
    ./klipper
    ./podman
    ./restic
    ./nginx
  ];
}
