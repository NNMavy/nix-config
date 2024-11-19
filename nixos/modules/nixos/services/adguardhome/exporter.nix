{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.adguard-exporter;

  app = "adguard-exporter";
  port = 9618;
in
{
  options.mySystem.services.adguard-exporter = {
    enable = mkEnableOption "Adguard Exporter";
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.adguard-exporter ];

    sops.secrets."services/adguardhome/password" = {
      sopsFile = ./secrets.sops.yaml;
    };

    sops.templates."adguard-exporter.env".content = ''
      ADGUARD_SERVERS=http://${config.networking.hostName}.${config.mySystem.internalDomain}:3000
      ADGUARD_USERNAMES=admin
      ADGUARD_PASSWORDS=${config.sops.placeholder."services/adguardhome/password"}
    '';

    systemd.services.adguard-exporter = {
      description = "adguard exporter of Prometheus metrics";
      wantedBy = [ "multi-user.target" ];
      wants = [ "adguardhome.service" ];
      after = [ "adguardhome.service" ];

      serviceConfig = {
        ExecStart = "${pkgs.adguard-exporter}/bin/adguard-exporter";
        Restart = "on-failure";
        User = "adguardhome";
        Group = "adguardhome";
        EnvironmentFile = config.sops.templates."adguard-exporter.env".path;
      };

    };

    services.vmagent = {
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "adguard";
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
