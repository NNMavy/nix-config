{ source, pkgs, lib, stdenv, python3, fetchFromGitHub }:
let
  pyEnv = python3.withPackages (ps: [
    ps.prometheus-client
    ps.setuptools
  ]);
in
stdenv.mkDerivation rec {
  inherit (source) pname version src;

  doCheck = false;

  pyWrapped = pyEnv.interpreter;

  buildInputs = [
    pyEnv
  ];

  installPhase = ''
    install -Dm755 ./gpsd_exporter.py $out/bin/gpsd_exporter.py
  '';

  meta = with lib; {
    homepage = "https://github.com/brendanbank/gpsd-prometheus-exporter";
    description = "Prometheus exporter for the gpsd GPS daemon. Collects metrics from the GPSD deamon. =";
  };
}
