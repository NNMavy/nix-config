{ inputs
, ...
}:
let
  custom = import ../pkgs;
in
{

  additions = custom.overlay;

  nur = inputs.nur.overlay;

  # The unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
