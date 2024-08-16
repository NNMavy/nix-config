{ source, pkgs, lib, stdenv, python3Packages, fetchPypi }:
let
  inherit (python3Packages) buildPythonApplication;
in
buildPythonApplication rec {
  inherit (source) pname version src;

  propagatedBuildInputs = [
    (with pkgs.python3Packages; [
      aiofiles
      GitPython
      mashumaro
      nest-asyncio
      pytest
      pytest-asyncio
      pytest-cov
      python-slugify
      pyyaml
    ])
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/allenporter/flux-local";
    description = "flux-local is a set of tools and libraries for managing a local flux gitops repository focused on validation steps to help improve quality of commits, PRs, and general local testing.";
  };
}
