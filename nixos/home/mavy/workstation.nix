{ lib, pkgs, self, config, inputs, ... }:
with config;
{
  imports = [
    ./global.nix
  ];

  myHome = {
    programs.firefox.enable = true;

    security = {
      ssh = {
        #TODO make this dynamic
        enable = true;
        matchBlocks = {
          mavy-wsl = {
            hostname = "mavy-wsl";
            port = 22;
          };

          peppernuts = {
            hostname = "peppernuts";
            port = 22;
          };
        };
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
        discord
        steam
        spotify
        prusa-slicer
        bitwarden
        yubioath-flutter
        yubikey-manager-qt
        flameshot
        vlc

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
