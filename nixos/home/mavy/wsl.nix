{ lib, pkgs, self, config, inputs, ... }:
with config;
{
  imports = [
    ./global.nix
  ];

  myHome = {
    programs = {
      firefox.enable = false;
      k9s.enable = true;
      fluxcd.enable = true;
    };

    security = {
      ssh = {
        #TODO make this dynamic
        enable = true;
      };
    };

    shell = {

      starship.enable = true;
      fish.enable = true;
      utilities.enable = true;
      wezterm.enable = true;

      git = {
        enable = true;
        username = "Rene Koens";
        email = "mavy@ninjanerd.eu";
        # signingKey = ""; # TODO setup signing keys n shit
      };
    };
  };

  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps

        # cli
        bat
        dbus
        direnv
        git
        nix-index
        python3
        fzf
        ripgrep

        brightnessctl



      ];

  };
}
