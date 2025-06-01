{ config, lib, pkgs, imports, boot, self, ... }:
# Role for headless servers
# covers raspi's, sbc, NUC etc, anything
# that is headless and minimal for running services

with lib;
{


  config = {


    # Enable monitoring for remote scraping
    mySystem = {
      system.noGraphicsPackages = true;
      system.motd.enable = true;
      security.wheelNeedsSudoPassword = false;
      services = {
        monitoring.enable = true;
        rebootRequiredCheck.enable = true;
        cockpit.enable = false;
        gatus.monitors = [{
          name = config.networking.hostName;
          group = "servers";
          url = "icmp://${config.networking.hostName}.${config.mySystem.internalDomain}";
          ui = {
            hide-hostname = true;
            hide-url = true;
          };
          interval = "1m";
          conditions = [ "[CONNECTED] == true" ];
        }];
      };
    };

    nix.settings = {
      # TODO factor out into mySystem
      # Avoid disk full issues
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
    };

    services.logrotate.enable = mkDefault true;

    # environment.noXlibs = mkDefault true;
    documentation = {
      enable = mkDefault false;
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };
    programs.command-not-found.enable = mkDefault false;

    services.pulseaudio.enable = false;


    services.udisks2.enable = mkDefault false;
  };

}
