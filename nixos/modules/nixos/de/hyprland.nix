{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.de.hyprland;
in
{
  options.mySystem.de.hyprland = {
    enable = mkEnableOption "hyprland";
    systrayicons = mkEnableOption "Enable systray icons" // { default = true; };
  };

  config = mkIf cfg.enable {

    # Ref: https://wiki.hyprland.org/Nix/

    # hyprland plz
    programs = {
      dconf.enable = true;
      hyprland.enable = true;
      hyprlock.enable = true;
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };

    services = {
      hypridle.enable = true;
      printing.enable = true;
      fprintd.enable = true;
    };

    # Fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji

        (nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "FiraCode Nerd Font" ];
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      wl-screenrec
      wl-clipboard
      wl-clip-persist
      cliphist
      xdg-utils
      wtype
      wlrctl
      waybar
      rofi-wayland
      wlogout

      pyprland
      hyprpicker
      hyprcursor
      hyprpaper

      wezterm

      fish
      starship
      helix

      qutebrowser
      zathura
      mpv
      imv
    ];
  };
}
