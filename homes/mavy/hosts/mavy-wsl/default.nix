{
  inputs,
  pkgs,
  config,
  ...
}: {
  home = {
    username = "mavy";
    homeDirectory = "/home/mavy";
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };

  modules = {
    editors = {
      neovim.enable = true;
      vscode = { 
        enable = true;
        wsl = true;
      };  
    };
    shell = {
      starship.enable = true;
      tmux.enable = true;
    };
  };
}
