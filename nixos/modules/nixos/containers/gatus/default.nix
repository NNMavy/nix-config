{ lib
, config
, pkgs
, self
, ...
}:
with lib;
let
  app = "gatus";
  image = "ghcr.io/twin/gatus:v5.14.0@sha256:acc0c116458a8d65ce48f7caea13881afa20bf5a405bb95230c51430eb9e2313";
  user = "568"; #string
  group = "568"; #string
  port = 8080; #int
  cfg = config.mySystem.services.${app};
  appFolder = "/var/lib/${app}";

  extraEndpoints = [
    # TODO refactor these out into their own file or fake host?
    # Servers
    {
      name = "pikvm";
      group = "servers";
      url = "icmp://pikvm.${config.mySystem.internalDomain}";
      interval = "1m";
      ui = {
        hide-hostname = true;
        hide-url = true;
      };
      alerts = [{ type = "telegram"; }];
      conditions = [ "[CONNECTED] == true" ];
    }
    {
      name = "nas";
      group = "servers";
      url = "icmp://nas.${config.mySystem.internalDomain}";
      interval = "1m";
      ui = {
        hide-hostname = true;
        hide-url = true;
      };
      alerts = [{ type = "telegram"; }];
      conditions = [ "[CONNECTED] == true" ];
    }
    # Infrastructure
    {
      name = "firewall";
      group = "infrastructure";
      url = "icmp://unifi.${config.mySystem.internalDomain}";
      interval = "1m";
      ui = {
        hide-hostname = true;
        hide-url = true;
      };
      alerts = [{ type = "telegram"; }];
      conditions = [ "[CONNECTED] == true" ];
    }

  ] ++ builtins.concatMap (cfg: cfg.config.mySystem.services.gatus.monitors)
    (builtins.attrValues self.nixosConfigurations);

  configAlerting = {
    # TODO really should make this libdefault and let modules overwrite failure-threshold etc.
    telegram = {
      token = "$TELEGRAM_TOKEN";
      id = "$TELEGRAM_ID";
    };
  };
  configVar =
    {
      metrics = true;
      endpoints = extraEndpoints;
      alerting = configAlerting;
      ui = {
        title = "Home Status | Gatus";
        header = "Home Status";
      };
    };

  configFile = builtins.toFile "config.yaml" (builtins.toJSON configVar);

in
{
  options.mySystem.services.${app} =
    {
      enable = mkEnableOption "${app}";
      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        description = "Services to add for montoring";
        default = [ ];
      };

    };

  config = mkIf cfg.enable {
    sops.secrets."services/${app}/env" = {
      sopsFile = ./secrets.sops.yaml;
      owner = config.users.users.kah.name;
      inherit (config.users.users.kah) group;
      restartUnits = [ "podman-${app}.service" ];
    };

    virtualisation.oci-containers.containers.${app} = {
      image = "${image}";
      user = "${user}:${group}";
      environmentFiles = [ config.sops.secrets."services/${app}/env".path ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${configFile}:/config/config.yaml:ro"
      ];

      extraOptions = [ "--cap-add=NET_RAW" ]; # Required for ping/etc to do monitoring
    };

    services.nginx.virtualHosts."${app}.${config.networking.domain}" = {
      useACMEHost = config.networking.domain;
      forceSSL = true;
      locations."^~ /" = {
        proxyPass = "http://${app}:${builtins.toString port}";
        extraConfig = "resolver 10.88.0.1;";
      };
    };

    services.vmagent = {
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "gatus";
            # scrape_timeout = "40s";
            static_configs = [
              {
                targets = [ "https://${app}.${config.mySystem.domain}" ];
                labels.instance = "${config.networking.hostName}";
              }
            ];
          }
        ];
      };
    };
  };
}
