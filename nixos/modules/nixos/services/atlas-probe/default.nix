{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.services.atlas-probe;
in
{
  options.mySystem.services.atlas-probe.enable = mkEnableOption "atlas-probe";

  config = mkIf cfg.enable
    {
      environment.systemPackages = with pkgs; [
        pkgs.flake.atlas-probe
      ];
    };

}
