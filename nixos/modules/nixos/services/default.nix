{
  imports = [
    ./monitoring.nix
    ./reboot-required-check.nix
    ./cockpit
    ./forgejo
    ./podman
    ./restic
    ./nginx
  ];
}
