{ source
, lib
, pkgs
, fetchFromGitHub
, ...
}:
pkgs.stdenv.mkDerivation rec {
  inherit (source) pname version src vendorSha256;

  hardeningDisable = [ "all" ];

  buildInputs = [
    pkgs.autoconf
    pkgs.automake
    pkgs.libtool
    pkgs.ncurses
    pkgs.openssl
  ];

  preConfigure = "autoreconf --install";

  configureFlags = [
    "--prefix=$(out)"
    "--sysconfdir=$(out)/etc"
    "--localstatedir=/var"
    "--libdir=$(out)/lib"
    "--runstatedir=/run"
    # --with-user=ripe-atlas
    # --with-group=ripe-atlas
    # --with-measurement-user=ripe-atlas-measurement
    "--enable-systemd=no"
    "--enable-chown=no"
    # --enable-setcap-install
  ];

  preInstall = ''
    mkdir -p $out/sbin $out/share/man/man8 $out/etc
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
