{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.${category}.${app};
  app = "klipper";
  category = "services";
  description = "Klipper printer service";
  image = "";
  user = "568"; #string
  group = "568"; #string
  port = 8080; #int
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
  host = "${app}" + (if cfg.dev then "-dev" else "");
  url = "${host}.${config.networking.domain}";
in
{
  options.mySystem.${category}.${app} =
    {
      enable = mkEnableOption "${app}";
      addToHomepage = mkEnableOption "Add ${app} to homepage" // { default = true; };
      monitor = mkOption
        {
          type = lib.types.bool;
          description = "Enable gatus monitoring";
          default = true;
        };
      prometheus = mkOption
        {
          type = lib.types.bool;
          description = "Enable prometheus scraping";
          default = true;
        };
      addToDNS = mkOption
        {
          type = lib.types.bool;
          description = "Add to DNS list";
          default = true;
        };
      dev = mkOption
        {
          type = lib.types.bool;
          description = "Development instance";
          default = false;
        };
      backup = mkOption
        {
          type = lib.types.bool;
          description = "Enable backups";
          default = true;
        };

      klipper-config = mkOption
        {
          type = lib.types.nullOr lib.types.path;
          description = "Printer config file";
          default = null;
        };


    };

  config = mkIf cfg.enable {

    ## Secrets
    # sops.secrets."${category}/${app}/env" = {
    #   sopsFile = ./secrets.sops.yaml;
    #   owner = user;
    #   group = group;
    #   restartUnits = [ "${app}.service" ];
    # };

    users.users.mavy.extraGroups = [ group ];


    # Folder perms - only for containers
    # systemd.tmpfiles.rules = [
    # "d ${appFolder}/ 0750 ${user} ${group} -"
    # ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [{ directory = appFolder; inherit user; inherit group; mode = "750"; }];
    };


    ## service
    services = {
      klipper = {
        enable = true;
        configFile = "${cfg.klipper-config}";

        # package = pkgs.danger-klipper-full-plugins;
        # firmware-package = pkgs.danger-klipper-firmware;
      };

      moonraker = {
        user = "${user}";
        enable = true;
        address = "0.0.0.0";
        settings = {
          octoprint_compat = { };
          history = { };
          authorization = {
            force_logins = true;
            cors_domains = [
              "*.local"
              "*.lan"
              "*://app.fluidd.xyz"
              "*://my.mainsail.xyz"
            ];
            trusted_clients = [
              "10.0.0.0/8"
              "127.0.0.0/8"
              "169.254.0.0/16"
              "172.16.0.0/12"
              "192.168.1.0/24"
              "FE80::/10"
              "::1/128"
            ];
          };
        };
      };

      mainsail = {
        enable = true;
      };
    };

    ### firewall config

    # networking.firewall = mkIf cfg.openFirewall {
    #   allowedTCPPorts = [ port ];
    #   allowedUDPPorts = [ port ];
    # };

    ### backups
    warnings = [
      (mkIf (!cfg.backup && config.mySystem.purpose != "Development")
        "WARNING: Backups for ${app} are disabled!")
    ];

    # services.restic.backups = mkIf cfg.backup (config.lib.mySystem.mkRestic
    #   {
    #     inherit app user;
    #     paths = [ appFolder ];
    #     inherit appFolder;
    #   });


    # services.postgresqlBackup = {
    #   databases = [ app ];
    # };



  };
}
