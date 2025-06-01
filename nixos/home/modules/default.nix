{ inputs
, config
, lib
, ...
}: {
  imports = [
    ./shell
    ./programs
    ./security
  ];

  options.myHome.username = lib.mkOption {
    type = lib.types.str;
    description = "users username";
    default = "mavy";
  };
  options.myHome.homeDirectory = lib.mkOption {
    type = lib.types.str;
    description = "users homedir";
    default = "mavy";
  };

  # Home-manager defaults
  config = {
    home.stateVersion = "24.05";

    programs = {
      home-manager.enable = true;
      git.enable = true;
    };

    xdg.enable = true;
  };

}
