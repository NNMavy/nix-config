{ lib
, pkgs
, fetchFromGitHub
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "ripe-atlas-software-probe";
  version = "5090";

  hardeningDisable = [ "all" ];

  src = fetchFromGitHub {
    owner = "RIPE-NCC";
    repo = pname;
    rev = version;
    hash = "sha256-s1aLjbaMbTVSy14w7uZAKU/kizLbl4fFFKUmpud0sNk=";
    fetchSubmodules = true;
  };

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
