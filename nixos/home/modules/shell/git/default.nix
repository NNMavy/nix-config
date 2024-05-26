{ pkgs
, config
, lib
, ...
}:
let
  cfg = config.myHome.shell.git;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.myHome.shell.git = {
    enable = lib.mkEnableOption "git";
    username = lib.mkOption {
      type = lib.types.str;
    };
    email = lib.mkOption {
      type = lib.types.str;
    };
    signingKey = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs = {
        gh.enable = true;
        gpg.enable = true;

        git = {
          enable = true;

          userName = cfg.username;
          userEmail = cfg.email;

          extraConfig = {
            core = {
              autocrlf = "input";
            };
            init = {
              defaultBranch = "main";
            };
            pull = {
              rebase = true;
            };
            rebase = {
              autoStash = true;
            };
          };
          aliases = {
            co = "checkout";
          };
          ignores = [
            # Mac OS X hidden files
            ".DS_Store"
            # Windows files
            "Thumbs.db"
            # asdf
            ".tool-versions"
            # Sops
            ".decrypted~*"
            "*.decrypted.*"
            # Python virtualenvs
            ".venv"
          ];
          # signing = lib.mkIf (cfg.signingKey != "") {
          #   signByDefault = true;
          #   key = cfg.signingKey;
          # };
        };
      };

      home.packages = [
        pkgs.git-filter-repo
        pkgs.tig
      ];

      # TODO: Move to global config
      home.file.".ssh/allowed_signers".text = ''
        mavy@ninjanerd.eu ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ/Tn0MifZtxPMhWpPtRzjXMeHKcFAYXvGKMuhPRbRxST8e2JQZ8j/5uCDRh8jXI4EYCZGtgHemuekiAsJBUvWpDImUGqySSot6gWkDnAlyEt2GUDdWByqjI6hlIXXrxqk6SSI8WCU7NnyIJj9INBK3+2dKr6pkoz3Eoneo7qfryxI8IOPFJeTFEOt2+8FPew3PtAwDeydR29/kIjGMXlidZC2w0ILmGjkkbYpgVMTUKIRBmsTjLy4wMp7Dr7H88DhJbLVC4fwv/LNlXoUOoFkYTNj/reT1OtBPZurmIQ6/28xPDFBmFZ++yVfQMrur/F9Z70dX3hYm+IOOZIC0hxL
      '';
    })
  ];
}
