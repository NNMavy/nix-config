{ config, lib, pkgs, imports, boot, self, inputs, ... }:
# Role for dev stations
# Could be a workstation or a headless server.

with config;
{

  mySystem = {
    security.one-password.enable = true;
    security.one-password.wsl = true;
    programs.docker-desktop.enable = true;

    shell.fish.enable = true;

    system.resticBackup.local.enable = false;
    system.resticBackup.remote.enable = false;
  };
}
