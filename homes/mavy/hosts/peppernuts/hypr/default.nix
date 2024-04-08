{
  inputs,
  pkgs,
  lib,
  ...
}: 
{

  home.file.".config/hypr/hypr.conf".source = ./configs/hypr.conf;

  xdg.configFile = {
    "rofi" = {
      source = ./configs/rofi;
      recursive = true;
    };
  };

}
