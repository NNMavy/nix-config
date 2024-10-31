{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.de.cosmic;
in
{
  options.mySystem.de.cosmic = {
    enable = mkEnableOption "cosmic";
  };

  config = mkIf cfg.enable {
    services = {
      desktopManager = {
        cosmic.enable = true;
      };
      displayManager = {
        cosmic-greeter.enable = true;
      };

      # Conventient services
      printing.enable = true;
      fprintd.enable = true;
    };
  };
}
