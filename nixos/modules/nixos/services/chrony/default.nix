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
    refclock PPS /dev/pps0 refid PPS lock NMEA precision 1e-7 poll 3 prefer
    refclock PHC /dev/ptp0 tai refid PHC poll 0
    refclock SHM 0 refid NMEA offset 0.050 precision 1e-3 poll 3 noselect
  '';

  ptp4lConfig = pkgs.writeText "ptp4l.conf" ''
    [global]
    # Only syslog every 1024 seconds
    summary_interval 10

    # Increase priority to allow this server to be chosen as the PTP grandmaster.
    priority1 10
    priority2 10

    [end0]
    # My LAN does not have hardware switches compatible with Layer-2 PTP, just Layer-3 PTP.
    network_transport UDPv4
    delay_mechanism E2E
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
        leapsectz right/UTC

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

    # Enable ptp
    environment.systemPackages = [ pkgs.linuxptp ];

    systemd.services.ptp4l = {
      description = "Precision Time Protocol service";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.linuxptp ];

      serviceConfig = {
        ExecStart = "${pkgs.linuxptp}/bin/ptp4l -f ${ptp4lConfig}";
        Nice = -10;
        Restart = "on-failure";
      };
    };

    systemd.services.phc2sys = {
      description = "Synchronizing PTP Hardware Clock from system time";
      wantedBy = [ "multi-user.target" ];
      after = [ "ptp4l.service" ];
      path = [ pkgs.linuxptp ];

      serviceConfig = {
        ExecStart = "${pkgs.linuxptp}/bin/phc2sys -s CLOCK_REALTIME -c end0 -w -u 1024";
        Nice = -10;
        Restart = "on-failure";
      };
    };
  };
}
