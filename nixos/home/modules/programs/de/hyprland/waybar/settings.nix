{ lib
, pkgs
, osConfig
, ...
}:
{
  config = lib.mkIf osConfig.mySystem.de.hyprland.enable {
    programs.waybar.settings.mainBar = {
      position = "bottom";
      layer = "top";
      height = 5;
      margin-top = 0;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      modules-left = [
        "custom/launcher"
        "hyprland/workspaces"
      ];
      modules-center = [
        "clock"
      ];
      modules-right = [
        "tray"
        "group/group-backlight"
        "pulseaudio"
        "battery"
        "network"
        "group/group-power"
      ];
      clock = {
        calendar = {
          format = { today = "<span color='#b4befe'><b><u>{}</u></b></span>"; };
        };
        format = " {:%H:%M}";
        tooltip = "true";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = " {:%d/%m}";
      };
      "hyprland/workspaces" = {
        active-only = false;
        disable-scroll = true;
        show-special = true;
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          "1" = "";
          "2" = "󰘙";
          "3" = "󰭹";
          "4" = "";
          "5" = "";
          browser = "";
          onepass = "󰟵";
          urgent = "";

          sort-by-number = true;
        };
        persistent-workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
        };
      };
      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "󰀂 ";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "󰖪 ";
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰖁  {volume}%";
        format-icons = {
          default = [ " " ];
        };
        scroll-step = 5;
        on-click = "pamixer -t";
      };
      battery = {
        format = "{icon} {capacity}%";
        format-icons = [ " " " " " " " " " " ];
        format-charging = " {capacity}%";
        format-full = " {capacity}%";
        format-warning = " {capacity}%";
        interval = 5;
        states = {
          warning = 20;
        };
        format-time = "{H}h{M}m";
        tooltip = true;
        tooltip-format = "{time}";
      };
      # Screen backlight group
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      backlight = {
        #device = "intel_backlight";
        format = "{icon}";
        format-icons = [ "" "" "" "" "" "" "" "" "" ];
        tooltip = false;
      };
      "backlight/slider" = { };
      "group/group-backlight" = {
        drawer = {
          children-class = "not-backlight";
          transition-duration = 500;
          transition-left-to-right = false;
        };
        # The first module in the list is shown as the initial button
        modules = [ "backlight" "idle_inhibitor" "backlight/slider" ];
        orientation = "inherit";
      };
      "custom/poweroff" = {
        format = "";
        on-click = "hyprctl dispatch exec 'systemctl poweroff'";
        tooltip = false;
      };
      "custom/quit" = {
        format = "󰗼";
        on-click = "hyprctl dispatch exit";
        tooltip = false;
      };
      "custom/reboot" = {
        format = "󰜉";
        on-click = "hyprctl dispatch exec 'systemctl reboot'";
        tooltip = false;
      };
      "custom/lock" = {
        format = "";
        on-click = "hyprctl dispatch exec 'loginctl lock-session'";
        tooltip = false;
      };
      "custom/suspend" = {
        format = "󰤄";
        on-click = "hyprctl dispatch exec 'loginctl lock-session & sleep 0.5 && systemctl suspend'";
        tooltip = false;
      };
      "group/group-power" = {
        drawer = {
          children-class = "not-power";
          transition-duration = 500;
          transition-left-to-right = false;
        };
        # The first module in the list is shown as the initial button
        modules = [ "custom/poweroff" "custom/quit" "custom/lock" "custom/suspend" "custom/reboot" ];
        orientation = "inherit";
      };
      "custom/launcher" = {
        format = "";
        on-click = "pkill wofi || wofi --show drun";
        on-click-right = "pkill wofi || wallpaper-picker";
        tooltip = "false";
      };
    };
  };
}
