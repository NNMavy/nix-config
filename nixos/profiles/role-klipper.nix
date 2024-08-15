{ config, lib, pkgs, imports, boot, self, ... }:
# Role for 3d printers
# covers raspi's, sbc, NUC etc, anything
# that is headless and minimal for running services

with lib;
{

  config = {
    # Enable monitoring for remote scraping
    mySystem.services.monitoring.enable = true;
    mySystem.services.rebootRequiredCheck.enable = true;
    mySystem.security.wheelNeedsSudoPassword = false;
    mySystem.system.motd.enable = true;

    nix.settings = {
      # TODO factor out into mySystem
      # Avoid disk full issues
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
    };

    services.logrotate.enable = mkDefault true;

    environment.noXlibs = mkDefault true;
    documentation = {
      enable = mkDefault false;
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };
    programs.command-not-found.enable = mkDefault false;

    sound.enable = false;
    hardware.pulseaudio.enable = false;

    services.udisks2.enable = mkDefault false;
  };

}
