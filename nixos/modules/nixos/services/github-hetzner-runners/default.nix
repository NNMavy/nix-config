{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.${category}.${app};
  app = "github-hetzner-runners";
  category = "services";
  description = "";
  user = "runners"; #string
  group = "runners"; #string
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



    };

  config = mkIf cfg.enable {

    ## Secrets
    sops.secrets = {
      "services/github-hetzner-runners/env".sopsFile = ./secrets.sops.yaml;
      "services/github-hetzner-runners/env".restartUnits = [ "${app}.service" ];
      "services/github-hetzner-runners/privkey" = {
        sopsFile = ./secrets.sops.yaml;
        path = "${appFolder}/.ssh/id_rsa";
        owner = user;
        inherit group;
        mode = "0644";
      };
      "services/github-hetzner-runners/pubkey" = {
        sopsFile = ./secrets.sops.yaml;
        path = "${appFolder}/.ssh/id_rsa.pub";
        owner = user;
        inherit group;
        mode = "0600";
      };
    };

    users.users.mavy.extraGroups = [ group ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [{ directory = appFolder; inherit user; inherit group; mode = "750"; }];
    };

    users.users."${user}" = {
      group = "${group}";
      isSystemUser = true;
      home = appFolder;
    };
    users.groups."${group}" = { };


    ## service
    environment.systemPackages = [ pkgs.github-hetzner-runners ];

    systemd.services.github-hetzner-runners = {
      description = "github-hetzner-runners agent";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.github-hetzner-runners ];

      serviceConfig = {
        EnvironmentFile = config.sops.secrets."services/github-hetzner-runners/env".path;
        ExecStart =
          let
            cmdArgs = builtins.concatStringsSep " " [
              "--service-mode"
              "--with-label hetzner"
              "--ssh-key ${appFolder}/.ssh/id_rsa.pub"
              "--workers 10"
              "--max-runners 10"
              "--max-powered-off-time 20"
              "--max-unused-runner-time 120"
              "--max-runner-registration-time 60"
              "--scale-up-interval 10"
              "--scale-down-interval 10"
              "--github-token $GITHUB_TOKEN"
              "--github-repository $GITHUB_REPOSITORY"
              "--hetzner-token $HETZNER_TOKEN"
              "--recycle on"
              "--end-of-life 50"
            ];
          in
          "${pkgs.github-hetzner-runners}/bin/github-hetzner-runners ${cmdArgs}";
        Restart = "on-failure";
        User = user;
        Group = user;
      };

    };

    ### backups
    warnings = [
      (mkIf (!cfg.backup && config.mySystem.purpose != "Development")
        "WARNING: Backups for ${app} are disabled!")
    ];

    services.restic.backups = mkIf cfg.backup (config.lib.mySystem.mkRestic
      {
        inherit app user;
        paths = [ appFolder ];
        inherit appFolder;
      });


    # services.postgresqlBackup = {
    #   databases = [ app ];
    # };



  };
}
