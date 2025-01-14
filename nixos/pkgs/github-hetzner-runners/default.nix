{ source, pkgs, lib, stdenv, python3Packages, fetchPypi }:
let
  inherit (python3Packages) buildPythonApplication;
in
buildPythonApplication rec {
  inherit (source) pname version src;


  preBuild = ''
    substituteInPlace setup.py \
      --replace "__VERSION__" "${version}"
  '';

  propagatedBuildInputs = [
    (with pkgs.python3Packages; [
      PyGithub
      hcloud
      requests-cache
      pyyaml
    ])
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/testflows/TestFlows-GitHub-Hetzner-Runners/tree/main";
    description = "Autoscaling Self-Hosted GitHub Actions Runners on Hetzner Cloud.";
  };
}
