{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.chrony;
  inherit (config.mySystem.services) gps;

  app = "chrony";
  port = 123;
  chronyPort = 323;

  gpsRefclockConfig = ''
    refclock PPS /dev/pps0 refid PPS prefer lock NMEA
    refclock SHM 0 refid NMEA offset 0.050 noselect
  '';
in
{
  options.mySystem.services.chrony = {
    enable = mkEnableOption "NTP Server";
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = true;
    };

    servers = mkOption {
      default = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
        "4.nixos.pool.ntp.org"
      ];
      description = mdDoc ''
        List of NTP servers to use for monitoring.

        These servers are strictly optional and not used by chrony to adjust
        the clock. Instead they can be monitored (e.g. with `chronyc sources`)
        to get a sense of our time compared to the community.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.chrony = {
      package = pkgs.unstable.chrony;
      enable = true;
      enableRTCTrimming = false;
      servers = [
      ];
      extraFlags = [
        "-d"
      ];
      extraConfig = ''
        allow
        lock_all
        rtcsync
        makestep 1 3

        ${gpsRefclockConfig}

        ${concatMapStrings
         (x: "server ${x} iburst\n")
         cfg.servers}
      '';
    };

    systemd.services.chronyd = {
      after = [ "gpsd.service" ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ port ];
    };

    mySystem.services.gatus.monitors = [
      {
        name = "${config.networking.hostName} NTP ";
        group = "ntp";
        url = "udp://${config.networking.hostName}.${config.mySystem.internalDomain}:${builtins.toString port}";
        interval = "1m";
        alerts = [{ type = "telegram"; }];
        conditions = [ "[CONNECTED] == true" ];
      }
    ];
  };
}
