{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./hyprland
  ];

  home = {
    username = "mavy";
    homeDirectory = "/home/mavy";
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };

  modules = {
    applications.vmware-horizon.enable = true;
    editors = {
      neovim.enable = true;
      # vscode.server-enable = true;
    };
    shell = {
      tmux.enable = true;
      alacritty.enable = true;
      starship.enable = true;
    };
  };
}
