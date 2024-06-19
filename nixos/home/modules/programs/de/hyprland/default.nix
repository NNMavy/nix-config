{ lib
, pkgs
, osConfig
, ...
}:
with lib.hm.gvariant; {

  config = lib.mkIf osConfig.mySystem.de.hyprland.enable {

    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, F, exec, firefox, "
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
    };

    # # add user packages
    # home.packages = with pkgs;  [
    #   dconf2nix
    # ];

    wayland.windowManager.hyprland.plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    ];
  };
}
