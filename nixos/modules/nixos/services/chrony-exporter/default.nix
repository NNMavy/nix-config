{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.chrony-exporter;

  app = "chrony-exporter";
  port = 9701;
in
{
  options.mySystem.services.chrony-exporter = {
    enable = mkEnableOption "NTP Exporter";
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.chrony-exporter ];

    systemd.services.chrony-exporter = {
      description = "chrony exporter of Prometheus metrics";
      wants = [ "chronyd.service" ];
      after = [ "chronyd.service" ];
      path = [ pkgs.chrony ];

      serviceConfig = {
        ExecStart = "${pkgs.chrony-exporter}/bin/chrony_exporter";
        Restart = "on-failure";
        User = "chrony";
        Group = "chrony";
      };

    };

    services.vmagent = {
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "chrony";
            # scrape_timeout = "40s";
            static_configs = [
              {
                targets = [ "http://127.0.0.1:${builtins.toString(port)}" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
        ];
      };
    };

  };
}
