{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.shell.git;
in {
  options.modules.shell.git = {
    enable = mkEnableOption "git";
    username = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
    };
    allowedSigners = mkOption {
      type = types.str;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.git = {
        enable = true;
        userName = cfg.username;
        userEmail = cfg.email;
        extraConfig = {
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          gpg.format = "ssh";
          "includeIf \"gitdir:~/fstq/\"" = { path = "~/.gitconfig.work"; };
          color = {ui = "auto";};
          core = {
            autocrlf = "input";
            editor = "nvim";
            pager = "delta";
          };
          delta = {
            navigate = "true";
            light = "false";
            features = "decorations";
            side-by-side = "true";
          };
          init = {defaultBranch = "main";};
          commit = {gpgSign = true;};
          user = {signingkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ/Tn0MifZtxPMhWpPtRzjXMeHKcFAYXvGKMuhPRbRxST8e2JQZ8j/5uCDRh8jXI4EYCZGtgHemuekiAsJBUvWpDImUGqySSot6gWkDnAlyEt2GUDdWByqjI6hlIXXrxqk6SSI8WCU7NnyIJj9INBK3+2dKr6pkoz3Eoneo7qfryxI8IOPFJeTFEOt2+8FPew3PtAwDeydR29/kIjGMXlidZC2w0ILmGjkkbYpgVMTUKIRBmsTjLy4wMp7Dr7H88DhJbLVC4fwv/LNlXoUOoFkYTNj/reT1OtBPZurmIQ6/28xPDFBmFZ++yVfQMrur/F9Z70dX3hYm+IOOZIC0hxL";};
          diff = {colorMoved = "default";};
          fetch = {prune = "true";};
          interactive = {diffFilter = "delta --color-only";};
          merge = {conflictstyle = "diff3";};
          pager = {branch = "false";};
          pull = {rebase = "true";};
          push = {autoSetupRemote = "true";};
          rebase = {autoStash = "true";};
        };
        aliases = {
          br = "branch";
          ci = "commit";
          co = "checkout";
          diffc = "diff --cached";
          lg = "lg1";
          lg1 = "lg1-specific --all";
          lg2 = "lg2-specific --all";
          lg3 = "lg3-specific --all";
          lg1-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
          lg2-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
          lg3-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";
          lsd = "log --graph --decorate --abbrev-commit --pretty=oneline --all";
          mrg = "merge --no-ff --log";
          oops = "commit --amend --no-edit";
          reword = "commit --amend";
          st = "status";
          uncommit = "reset --soft HEAD~1";
          undo = "checkout --";
        };
        ignores = [
          ".direnv/**"
          "result"
          ".DS_Store"
          ".decrypted-*"
        ];
      };

      programs.fish = {
        functions = {
          gcb = {
            description = "Create a new branch from main";
            body = "git checkout main && git pull && git checkout -b $argv";
          };
        };
        shellAliases = {
          gl = "git lg";
          gst = "git status";
        };
      };

      home.packages = with pkgs; [delta fzf];
      home.file.".ssh/allowed_signers".text = cfg.allowedSigners;
    })
    (mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      programs.git = {
        extraConfig = {
          credential = {helper = "osxkeychain";};
        };
      };
    })
  ];
}
