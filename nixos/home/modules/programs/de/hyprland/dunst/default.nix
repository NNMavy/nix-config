{ lib
, pkgs
, osConfig
, config
, ...
}:
let

  accent = "\$${config.catppuccin.accent}";
  accentAlpha = "\$${config.catppuccin.accent}Alpha";
  font = "JetBrains Mono Regular";
in
{
  config = lib.mkIf osConfig.mySystem.de.hyprland.enable {
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Colloid-teal-dark";
        package = pkgs.colloid-icon-theme;
      };
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "5x5";
          origin = "top-right";
          corner_radius = 10;
          frame_color = "#8aadf4";
          font = "JetBrains Mono Regular 11";
        };
      };
    };
  };
}
