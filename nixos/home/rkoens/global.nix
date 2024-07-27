{ lib, pkgs, self, config, ... }:
with config;
{

  imports = [
    ../modules
  ];

  config = {
    myHome = {
      username = "rkoens";
      homeDirectory = "/home/rkoens/";
    };


    systemd.user.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      ZDOTDIR = "/home/pinpox/.config/zsh";
    };

    home = {
      # Install these packages for my user
      packages = with pkgs; [
        eza
        htop
        unzip
      ];

      sessionVariables = {
        # Workaround for alacritty (breaks wezterm and other apps!)
        # LIBGL_ALWAYS_SOFTWARE = "1";
        EDITOR = "vim";
        VISUAL = "vim";
        ZDOTDIR = "/home/pinpox/.config/zsh";
        SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
      };

    };

  };
}
