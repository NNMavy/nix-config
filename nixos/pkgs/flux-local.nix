{ pkgs, lib, stdenv, buildPythonPackage, pythonOlder, fetchPypi }:

buildPythonPackage rec {
  pname = "flux_local";
  version = "5.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2d45abf1eebe6d79756c73cb60a182c4928f4b3c14818e91bac3fb38047ba252";
  };

  disabled = pythonOlder "3.10";

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
