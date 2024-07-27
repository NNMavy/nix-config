{ lib
, pkgs
, osConfig
, config
, ...
}:
let
  styleFile = "${config.catppuccin.sources.waybar}/themes/${config.catppuccin.flavor}.css";
  accent = "\@${config.catppuccin.accent}";
  accentAlpha = "\@${config.catppuccin.accent}Alpha";
  custom = {
    font = "FiraCode Nerd Font";
    font_size = "15px";
    font_weight = "bold";
    opacity = "0.98";
  };
in
{
  config = lib.mkIf osConfig.mySystem.de.hyprland.enable {
    programs.waybar.style = ''
      @import "${styleFile}";

      * {
          border: none;
          border-radius: 0px;
          color: @text;
          padding: 0;
          margin: 0;
          min-height: 0px;
          font-family: ${custom.font};
          font-weight: ${custom.font_weight};
          opacity: ${custom.opacity};
      }

      window#waybar {
          background-color: alpha(@base, 0.7);
          border-top: solid alpha(@surface1, 0.7) 2;
      }

      #workspaces {
          font-size: 18px;
          padding-left: 15px;

      }
      #workspaces button {
          padding-left:  6px;
          padding-right: 6px;
      }
      #workspaces button.empty {
          color: ${accentAlpha};
      }
      #workspaces button.active {
          color: ${accent};
      }

      #tray, #pulseaudio, #network, #cpu, #memory, #disk, #clock, #battery {
          font-size: ${custom.font_size};
      }

      #cpu {
          padding-left: 15px;
          padding-right: 9px;
          margin-left: 7px;
      }
      #memory {
          padding-left: 9px;
          padding-right: 9px;
      }
      #disk {
          padding-left: 9px;
          padding-right: 15px;
      }

      #tray {
          padding: 0 20px;
          margin-left: 7px;
      }

      #idle_inhibitor {
        border-radius: 1rem 0px 0px 1rem;
        margin-left: 1rem;
      }

      #pulseaudio {
          padding-left: 15px;
          padding-right: 9px;
          margin-left: 7px;
      }
      #battery {
          padding-left: 9px;
          padding-right: 9px;
      }
      #network {
          padding-left: 9px;
          padding-right: 15px;
      }

      #clock {
          padding-left: 9px;
          padding-right: 15px;
      }

      #custom-launcher {
          font-size: 20px;
          color: #b4befe;
          font-weight: ${custom.font_weight};
          padding-left: 10px;
          padding-right: 15px;
      }

      #idle_inhibitor,
      #custom-quit,
      #custom-lock,
      #custom-suspend,
      #custom-reboot,
      #custom-poweroff {
        background-color: @surface0;
        padding: 0.5rem 1rem;
        margin: 5px 0 0 0;
      }

      /* Powermenu group */
      #custom-quit {
          border-radius: 1rem 0px 0px 1rem;
          color: ${accent};
      }
      #custom-lock {
          border-radius: 0;
          color: ${accent};
      }
      #custom-suspend {
          border-radius: 0;
          color: ${accent};
      }
      #custom-reboot {
          border-radius: 0;
          color: @peach;
      }
      #custom-poweroff {
          margin-right: 1rem;
          border-radius: 1rem;
          color: @red;
      }
      #backlight {
        color: @yellow;
        border-radius: 1rem 0px 0px 1rem;
      }
      #backlight-slider slider {
        min-height: 0px;
        min-width: 0px;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
      }
      #backlight-slider trough {
        min-width: 80px;
        min-height: 10px;
        border-radius: 5px;
        background-color: black;
      }
      #backlight-slider highlight {
        min-width: 10px;
        border-radius: 5px;
        background-color: @text;
      }

      /* Make tooltips follow catpuccin */
      tooltip {
        background: @base;
        border: 1px solid @pink;
      }
      tooltip label {
        color: @text;
      }
    '';
  };
}
