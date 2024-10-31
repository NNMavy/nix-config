{ lib
, config
, pkgs
, ...
}:
with lib;
let
  app = "backrest";
  image = "garethgeorge/backrest:v1.6.1@sha256:289c310aa4c7828064375f73a5d879c42b1e180290e2fdf2b0e5d1af1e669f94";
  user = "568"; #string
  group = "568"; #string
  port = 9898; #int
  cfg = config.mySystem.services.${app};
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
in
{
  options.mySystem.services.${app} =
    {
      enable = mkEnableOption "${app}";
      addToHomepage = mkEnableOption "Add ${app} to homepage" // { default = true; };
    };

  config = mkIf cfg.enable {
    # ensure folder exist and has correct owner/group
    systemd.tmpfiles.rules = [
      "d ${appFolder}/config 0750 ${user} ${group} -"
      "d ${appFolder}/data 0750 ${user} ${group} -"
      "d ${appFolder}/cache 0750 ${user} ${group} -"
    ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [{ directory = appFolder; inherit user; inherit group; mode = "750"; }];
    };

    virtualisation.oci-containers.containers.${app} = {
      image = "${image}";
      user = "${user}:${group}";
      environment = {
        BACKREST_PORT = "9898";
        BACKREST_DATA = "/data";
        BACKREST_CONFIG = "/config/config.json";
        XDG_CACHE_HOME = "/cache";
      };
      volumes = [
        "${appFolder}/config:/config:rw"
        "${appFolder}/data:/data:rw"
        "${appFolder}/cache:/cache:rw"
        #"${config.mySystem.nasFolder}/backup/nixos/nixos:/repos:rw"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    services.nginx.virtualHosts."${app}.${config.networking.domain}" = {
      useACMEHost = config.networking.domain;
      forceSSL = true;
      locations."^~ /" = {
        proxyPass = "http://${app}:${builtins.toString port}";
        extraConfig = "resolver 10.88.0.1;";
      };
    };


    # mySystem.services.homepage.infrastructure = mkIf cfg.addToHomepage [
    #   {
    #     Backrest = {
    #       icon = "${app}.svg";
    #       href = "https://${app}.${config.mySystem.domain}";

    #       description = "Local restic backup browser";
    #       container = "${app}";
    #     };
    #   }
    # ];

    mySystem.services.gatus.monitors = [{

      name = app;
      group = "containers";
      url = "https://${app}.${config.mySystem.domain}";
      interval = "1m";
      ui = {
        hide-hostname = true;
        hide-url = true;
      };
      conditions = [ "[CONNECTED] == true" "[STATUS] == 200" "[RESPONSE_TIME] < 50" ];
    }];

  };
}
