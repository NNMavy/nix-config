{ source, pkgs, stdenv, lib, rustPlatform, makeBinaryWrapper }:

rustPlatform.buildRustPackage rec {
  inherit (source) pname version src;

  cargoLock = source.cargoLock."Cargo.lock";
  enableParallelBuilding = true;

  outputs = [ "out" ];

  installPhase = ''
    mkdir $out
    mkdir -p $out/bin/
    mkdir -p $out/etc/systemd/system/

    install -D -m 0755 "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/chrony_exporter" "$out/bin/chrony_exporter"
    install -D -m 0644 "data/chrony_exporter.service" "$out/etc/systemd/system/chrony_exporter.service"
    install -D -m 0644 "data/chrony_exporter.socket" "$out/etc/systemd/system/chrony_exporter.socket"
  '';
}
