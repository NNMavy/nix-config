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
    environment.systemPackages = [ pkgs.gpsd-prometheus-exporter ];

    systemd.services.gpsd-exporter = {
      description = "gpsd exporter of Prometheus metrics";
      wants = [ "gpsd.service" ];
      after = [ "gpsd.service" ];
      path = [ pkgs.gpsd ];

      serviceConfig = {
        ExecStart =
          let
            cmdArgs = builtins.concatStringsSep " " [
              "-v"
              "--pps-histogram" # Observe the clock offset from the pps signal
              "--offset-from-geopoint" # Measure an offset from a fixed geo point
              "--geopoint-lon 4.740363"
              "--geopoint-lat 51.621692"
              "--pps-time1 0.0"
            ];
          in
            "${pkgs.gpsd-prometheus-exporter}/bin/gpsd_exporter.py ${cmdArgs}";
        Restart = "on-failure";
        User = "gpsd";
        Group = "gpsd";
        Environment = ''
          PYTHONUNBUFFERED=1
        '';
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
