{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.${category}.${app};
  app = "atlas-probe";
  category = "services";
  description = "";
  image = "jamesits/ripe-atlas";
  user = "101"; #string
  group = "999"; #string
  # port = ; #int
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
  host = "${app}" + (if cfg.dev then "-dev" else "");
  #url = "${host}.${config.networking.domain}";
in
{
  options.mySystem.${category}.${app} =
    {
      enable = mkEnableOption "${app}";
      backup = mkOption
        {
          type = lib.types.bool;
          description = "Enable backups";
          default = true;
        };
    };

  config = mkIf cfg.enable {

    users.users.mavy.extraGroups = [ group ];

    # ensure folder exist and has correct owner/group
    systemd.tmpfiles.rules = [
      "d ${appFolder}/etc 0750 ${user} ${group} -"
      "d ${appFolder}/status 0750 ${user} ${group} -"
    ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [{ directory = appFolder; inherit user; inherit group; mode = "750"; }];
    };

    virtualisation.oci-containers.containers.${app} = {
      inherit image;

      environment = {
        RXTXRPT = "yes";
      };

      volumes = [
        "${appFolder}/etc:/var/atlas-probe/etc"
        "${appFolder}/status:/var/atlas-probe/status"
      ];

      extraOptions = [
        "--cap-drop=ALL"
        "--cap-add=CHOWN"
        "--cap-add=SETUID"
        "--cap-add=SETGID"
        "--cap-add=DAC_OVERRIDE"
        "--cap-add=NET_RAW"
      ];
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

  };
}
