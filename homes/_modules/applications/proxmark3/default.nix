{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.applications.proxmark3;
in {
  options.modules.applications.proxmark3 = {
    enable = mkEnableOption "proxmark3";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      proxmark3
    ];
  };
}
