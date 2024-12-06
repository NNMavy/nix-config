{ source
, lib
, pkgs
, fetchurl
, stdenvNoCC
, makeWrapper
, dpkg
, autoPatchelfHook
, ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "atlas-probe";
  version = "5100";

  srcs = [
    (fetchurl {
      url = "https://ftp.ripe.net/ripe/atlas/software-probe/debian/dists/bookworm/main/binary-amd64/ripe-atlas-probe_${version}_all.deb";
      sha256 = "sha256-/klHcgKrn7kvhvZl/cquaqFIQKs0H4tjPDFTHrZOpgM=";
    })
    (fetchurl {
      url = "https://ftp.ripe.net/ripe/atlas/software-probe/debian/dists/bookworm/main/binary-amd64/ripe-atlas-common_${version}_amd64.deb";
      sha256 = "sha256-CjWeGwb5FFmX24XDoe10y/dBZoW783MDab9/P7GIOHc=";
    })
  ];

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    glib
    openssl
  ];

  dontBuild = true;
  dontConfigure = true;

  # sourceRoot = "./";
  unpackCmd = "dpkg --fsys-tarfile $curSrc | tar --extract -C atlas-probe";


  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    mv -t $out/ usr/*

    runHook postInstall
  '';

  meta = with lib; {
    description = "Atlas Ripe Software Probe";
    homepage = "https://atlas.ripe.net/docs/howtos/software-probes.html";
    license = licenses.gpl3;
    maintainers = with maintainers; [ mavy ];
    mainProgram = "atlas-probe";
    platforms = platforms.unix;
  };
}
