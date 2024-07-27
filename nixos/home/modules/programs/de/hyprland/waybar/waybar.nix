{ lib
, pkgs
, osConfig
, ...
}:
{
  config = lib.mkIf osConfig.mySystem.de.hyprland.enable {
    programs.waybar = {
      enable = true;
    };
    programs.waybar.package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
    });
  };
}
