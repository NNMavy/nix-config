{ lib, pkgs, self, config, inputs, ... }:
with config;
{
  imports = [
    ./global.nix
    inputs.catppuccin.homeManagerModules.catppuccin
  ];


  # Set theme for home-manager
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
  };

  programs = {

    # TODO: Move to module
    kitty = {
      enable = true;
      catppuccin = {
        enable = true;
        inherit (config.catppuccin) flavor;
      };
    };
  };

  myHome = {
    programs = {
      firefox.enable = true;
      k9s.enable = true;
      fluxcd.enable = true;
    };

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
      };
    };
  };



  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps
        discord
        slack
        spotify
        orca-slicer
        yubioath-flutter
        yubikey-manager-qt
        flameshot
        flake.multiviewer-for-f1
        vlc

        # cli
        bat
        brightnessctl
        dbus
        direnv
        git
        nix-index
        python3
        fzf
        ripgrep

      ];

  };
}
