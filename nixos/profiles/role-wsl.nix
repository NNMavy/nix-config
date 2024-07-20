{ config, lib, pkgs, imports, boot, self, inputs, ... }:
# Role for dev stations
# Could be a workstation or a headless server.

with config;
{

  imports = [
    inputs.nixos-wsl.nixosModules.default
    # Import this here since it is broken with nixos-hardware
    ./nixos/modules/nixos/programs/docker-desktop
  ];

  mySystem = {
    security.one-password.enable = true;
    security.one-password.wsl = true;
    programs.docker-desktop.enable = true;
  };
}
