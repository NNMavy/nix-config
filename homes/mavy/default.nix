{
  inputs,
  pkgs,
  config,
  lib,
  hostname,
  ...
}:
with lib; let
  extensions = let
    inherit (inputs.nix-vscode-extensions.extensions.${pkgs.system}) vscode-marketplace open-vsx;
  in
    with vscode-marketplace; [
      aaron-bond.better-comments
      alefragnani.bookmarks
      alefragnani.project-manager
      belfz.search-crates-io
      bierner.markdown-mermaid
      bmalehorn.vscode-fish
      davidanson.vscode-markdownlint
      esbenp.prettier-vscode
      fcrespo82.markdown-table-formatter
      fnando.linter
      foxundermoon.shell-format
      github.vscode-github-actions
      github.vscode-pull-request-github
      golang.go
      gruntfuggly.todo-tree
      hashicorp.terraform
      ieni.glimpse
      jnoortheen.nix-ide
      kamadorueda.alejandra
      mhutchie.git-graph
      mikestead.dotenv
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-playwright.playwright
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      oderwat.indent-rainbow
      pkief.material-icon-theme
      redhat.vscode-yaml
      rust-lang.rust-analyzer
      serayuzgur.crates
      signageos.signageos-vscode-sops
      svelte.svelte-vscode
      tamasfe.even-better-toml
      usernamehw.errorlens
      vadimcn.vscode-lldb
      yinfei.luahelper
      yzhang.markdown-all-in-one
    ];
in {
  imports = [
    ../_modules
    ./hosts/${hostname}
  ];
  
  modules = {
    editors = {
      vscode = {
        inherit extensions;
        configPath = "${config.home.homeDirectory}/.local/nix-config/homes/mavy/config/editors/vscode/settings.json";
        keybindingsPath = "${config.home.homeDirectory}/.local/nix-config/homes/mavy/config/editors/vscode/keybindings.json";
      };
    };

    security = {
      one-password = {
        enable = true;
        wsl = true;
      };
      gnupg.enable = true;
      ssh = {
        enable = true;
      };
    };

    shell = {
      fish.enable = true;
      git = {
        enable = true;
        username = "Rene Koens";
        email = "mavy@ninjanerd.eu";
        allowedSigners = builtins.readFile ./config/ssh/allowed_signers;
      };
    };
  };
}
