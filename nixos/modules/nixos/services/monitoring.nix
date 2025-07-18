{ lib
, config
, self
, ...
}:
with lib;
let
  cfg = config.mySystem.services.monitoring;
  urlVmAgent = "vmagent-${config.networking.hostName}.${config.networking.domain}";
  portVmAgent = 8429; #int
in
{
  options.mySystem.services.monitoring.enable = mkEnableOption "Prometheus Monitoring";
  options.mySystem.monitoring.scrapeConfigs.node-exporter = mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Prometheus node-exporter scrape targets";
    default = [ ];
  };


  config = mkIf cfg.enable {

    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "diskstats"
          "filesystem"
          "loadavg"
          "meminfo"
          "netdev"
          "stat"
          "time"
          "uname"
          "systemd"
        ];
      };
      smartctl = {
        enable = true;
      };


    };

    services.vmagent = {
      enable = true;
      remoteWrite.url = "https://prometheus.nnhome.eu/api/v1/write";
      extraArgs = lib.mkForce [
        #"-remoteWrite.label=instance=${config.networking.hostName}"
        "-sortLabels"
        "-remoteWrite.forcePromProto=\"true\""
      ];
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "node";
            # scrape_timeout = "40s";
            static_configs = [
              {
                targets = [ "http://127.0.0.1:9100" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
          {
            job_name = "smartctl";
            # scrape_timeout = "40s";
            static_configs = [
              {
                targets = [ "http://127.0.0.1:9633" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
          {
            job_name = "vmagent";
            # scrape_interval = "10s";
            static_configs = [
              {
                targets = [ "127.0.0.1:8429" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
        ];
      };
    };

    services.nginx.virtualHosts.${urlVmAgent} = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
      locations."^~ /" = {
        proxyPass = "http://127.0.0.1:${builtins.toString portVmAgent}";
      };
    };

    mySystem.monitoring.scrapeConfigs.node-exporter = [ "${config.networking.hostName}:${toString config.services.prometheus.exporters.node.port}" ];

  };

}
