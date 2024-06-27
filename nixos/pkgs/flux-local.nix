{ pkgs, lib, stdenv, buildPythonPackage, pythonOlder, fetchPypi }:

buildPythonPackage rec {
  pname = "flux-local";
  version = "5.3.1";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    python = "py3";
    sha256 = "43a782100c6055f9f4ba428f2bf6989605fae09af7e16b378c01c00fee4979fb";
  };

  disabled = pythonOlder "3.10";

  propagatedBuildInputs = [
    ( with pkgs.python3Packages; [
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
    homepage = https://github.com/allenporter/flux-local;
    description = "flux-local is a set of tools and libraries for managing a local flux gitops repository focused on validation steps to help improve quality of commits, PRs, and general local testing.";
  };
}
