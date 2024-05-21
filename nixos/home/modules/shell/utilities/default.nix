{ pkgs
, config
, lib
, ...
}:
let
  ignorePatterns = ''
    !.env*
    !.github/
    !.gitignore
    !*.tfvars
    .terraform/
    .target/
    /Library/'';
  cfg = config.myHome.shell.utilities;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.myHome.shell.utilities = {
    enable = lib.mkEnableOption "utilities";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      alejandra
      bat
      dig
      du-dust
      duf
      envsubst
      eza
      fd
      fzf
      gh
      go-task
      jq
      nodePackages.prettier
      nvd
      pre-commit
      protobuf
      python3
      qrencode
      redis
      restic
      shellcheck
      sops
      unixtools.watch
      wget
      yq-go
    ];

    home.file = {
      ".rgignore".text = ignorePatterns;
      ".fdignore".text = ignorePatterns;
      ".digrc".text = "+noall +answer"; # Cleaner dig commands
    };

    # Environment configuration
    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "fd -H -E '.git'";
    };

    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      lazygit = {
        enable = true;
        settings = {
          gui.paging = {
            colorArg = "always";
            pager = "delta --dark --paging=never --syntax-theme base16-256 --diff-so-fancy";
          };
        };
      };
      atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
        settings = {
          sync_address = "https://atuin.nnhome.eu";
          auto_sync = true;
          sync_frequency = "1m";
          search_mode = "fuzzy";
        };
      };
      ripgrep = {
        enable = true;
        arguments = ["--glob=!vendor" "--hidden" "--line-number" "--no-heading" "--sort=path"];
      };
      zoxide = {
        enable = true;
      };
    };
  };
}
