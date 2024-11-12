{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.chrony;
  gps = config.mySystem.services.gps;

  app = "chrony";
  port = 123;
  chronyPort = 323;

  gpsRefclockConfig = ''
    refclock PPS ${gps.pps.path} refid ${gps.pps.refid} prefer lock ${gps.pps.lock}
    refclock SHM 0 refid ${gps.serial.refid} ${if gps.serial.offset != null then "offset ${gps.serial.offset} " else ""} noselect
  '';
in
{
  options.mySystem.services.chrony = {
    enable = mkEnableOption "NTP Server";
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = true;
    };

    allowedIPv6Ranges = mkOption {
      default = [ { address = "fe80::"; prefixLength = 10; } ];
      example = [
        { address = "fe80::"; prefixLength = 10; }
        { address = "2a02:a472:e8b3::"; prefixLength = 48; }
      ];
      description = mdDoc ''
        The IPv6 Ranges that will be allowed to query our NTP server.

        This will open the firewall and configure the ACL's in chrony.
      '';
    };

    allowedIPv4Ranges = mkOption {
      default = [ { address = "127.0.0.1"; prefixLength = 8; } ];
      example = [
        { address = "127.0.0.1"; prefixLength = 8; }
        { address = "172.16.20.0"; prefixLength = 24; }
      ];
      description = mdDoc ''
        The IPv4 Ranges that will be allowed to query our NTP server.

        This will open the firewall and configure the ACL's in chrony.
      '';
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

        ${if gps.enable then gpsRefclockConfig else ""}

        ${concatMapStrings
         (x: "server ${x} iburst\n")
         cfg.servers}
      '';
    };

    systemd.services.chronyd = {
      after = [ "gpsd.service" ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ 123 323 ];
    };

    # mySystem.services.gatus.monitors = [
    #   {
    #     name = "${config.networking.hostName} external dns";
    #     group = "ntp";
    #     url = "${config.networking.hostName}.${config.mySystem.internalDomain}:${builtins.toString port}";
    #     dns = {
    #       query-name = "cloudflare.com";
    #       query-type = "A";
    #     };
    #     interval = "1m";
    #     alerts = [{ type = "telegram"; }];
    #     conditions = [ "[DNS_RCODE] == NOERROR" ];
    #   }
    #   {
    #     name = "${config.networking.hostName} internal dns";
    #     group = "dns";
    #     url = "${config.networking.hostName}.${config.mySystem.internalDomain}:${builtins.toString port}";
    #     dns = {
    #       query-name = "unifi.${config.mySystem.internalDomain}";
    #       query-type = "A";
    #     };
    #     interval = "1m";
    #     alerts = [{ type = "telegram"; }];
    #     conditions = [ "[DNS_RCODE] == NOERROR" ];
    #   }
    # ];

  };
}
