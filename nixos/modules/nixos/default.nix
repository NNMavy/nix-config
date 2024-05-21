{ lib, config, ... }:
with lib;
{
  imports = [
    ./system
    ./programs
    ./services
    ./de
    ./editor
    #./hardware
    #./containers
    ./lib.nix
    ./security
  ];

  options = {
    mySystem = {
      persistentFolder = mkOption {
        type = types.str;
        description = "persistent folder for nixos mutable files";
        default = "/persist";
      };

      nasFolder = mkOption {
        type = types.str;
        description = "folder where nas mounts reside";
        default = "/mnt/nas";
      };
      domain = mkOption {
        type = types.str;
        description = "domain for hosted services";
        default = "";
      };
      internalDomain = mkOption {
        type = types.str;
        description = "domain for local devices";
        default = "";
      };
      purpose = mkOption {
        type = types.str;
        description = "System purpose";
        default = "Production";
      };
      monitoring.prometheus.scrapeConfigs = mkOption {
        type = lib.types.listOf lib.types.attrs;
        description = "Prometheus scrape targets";
        default = [ ];
      };
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${config.mySystem.persistentFolder} 777 - - -" #The - disables automatic cleanup, so the file wont be removed after a period
    ];
  };
}
