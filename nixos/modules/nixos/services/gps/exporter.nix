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
    environment.systemPackages = [ pkgs.chrony-exporter ];

    systemd.services.gpsd-exporter = {
      description = "gpsd exporter of Prometheus metrics";
      wants = [ "gpsd.service" ];
      after = [ "gpsd.service" ];
      path = [ pkgs.gpsd ];

      serviceConfig = {
        ExecStart = "${pkgs.chrony-exporter}/bin/chrony_exporter";
        Restart = "on-failure";
        User = "gpsd";
        Group = "gpsd";
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
                targets = [ "http://127.0.0.1:${cfg.port}" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
        ];
      };
    };

  };
}
