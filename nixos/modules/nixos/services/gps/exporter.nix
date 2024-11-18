{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.gpsd-exporter;

  app = "gpsd-exporter";
  port = 9015;
in
{
  options.mySystem.services.gpsd-exporter = {
    enable = mkEnableOption "gpsd Exporter";
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gpsd-prometheus-exporter
    ];

    systemd.services.gpsd-exporter = {
      description = "gpsd exporter of Prometheus metrics";
      wantedBy = [ "multi-user.target" ];
      wants = [ "gpsd.service" ];
      after = [ "gpsd.service" ];
      path = [ pkgs.gpsd ];

      serviceConfig = {
        ExecStart =
          let
            cmdArgs = builtins.concatStringsSep " " [
              "-v" # Verbose
              "--pps-histogram" # generate histogram data from pps devices
              "--offset-from-geopoint" # track offset (x,y offset and distance) from a stationary location.
              "--geopoint-lon 4.738000" # Longitude of a fixed stationary location.
              "--geopoint-lat 51.621750" # Latitude of a fixed stationary location.
              "--pps-time1 0.050" # Local pps clock (offset) time1
            ];
          in
          "${pkgs.gpsd-prometheus-exporter}/bin/gpsd_exporter.py ${cmdArgs}";
        Restart = "on-failure";
        User = "gpsd";
        Group = "gpsd";
        Environment = [
          "PYTHONPATH=${pkgs.gpsd}/lib/python3.11/site-packages"
          "PYTHONUNBUFFERED=1"
        ];
      };
    };

    services.vmagent = {
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "gpsd";
            # scrape_timeout = "40s";
            static_configs = [
              {
                targets = [ "http://127.0.0.1:${builtins.toString port}" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
        ];
      };
    };

  };
}
