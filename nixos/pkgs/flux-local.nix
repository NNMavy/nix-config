{ pkgs, lib, stdenv, python3Packages, fetchPypi }:
let
  inherit (python3Packages) buildPythonApplication;
  sourceData = pkgs.callPackage ./_sources/generated.nix { };
  packageData = sourceData.flux-local;
in
buildPythonApplication rec {
  inherit (packageData) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    (with pkgs.python3Packages; [
      aiofiles
      GitPython
      mashumaro
      nest-asyncio
      setuptools
      pytest
      pytest-asyncio
      pytest-cov
      python-slugify
      pyyaml
      oras
    ])
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/allenporter/flux-local";
    description = "flux-local is a set of tools and libraries for managing a local flux gitops repository focused on validation steps to help improve quality of commits, PRs, and general local testing.";
  };
}
