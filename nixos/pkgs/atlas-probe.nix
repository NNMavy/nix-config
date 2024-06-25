{ lib
, pkgs
, ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "atlas-probe";
  version = "2.6.3";

  hardeningDisable = [ "format" ];

  src = pkgs.fetchzip {
    url = "https://github.com/RIPE-NCC/ripe-atlas-probe-measurements/archive/refs/tags/2.6.3.tar.gz";
    sha256 = "sha256-JPLwlnV8UYiiiPNLTT92nvxpB6l9kLGxy4iEUzdacH0=";
    stripRoot = true;
  };

  buildInputs = [
    pkgs.autoconf
    pkgs.automake
    pkgs.libtool
    pkgs.ncurses
  ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=$out/atlas" ];

  configurePhase = ''
  '';

  buildPhase = ''
    cd libevent-2.1.11-stable  # first build libevent
    autoreconf --install
    ./configure --prefix=$out/atlas
    make install
    cd ../
    make menuconfig     # This creates a file called ".config"
    make                # This creates the "busybox" executable
  '';

  installPhase = ''
    make install
    # mkdir -p %{buildroot}%{installpath}/{bin,bin/arch/centos-sw-probe,bin/arch/linux,bb-13.3,etc,lib,state}
    # cp -r ./_install/* %{buildroot}%{installpath}/bb-13.3
    # cp ./libevent-2.1.11-stable/.libs/libevent-*so* %{buildroot}%{installpath}/lib
    # cp ./libevent-2.1.11-stable/.libs/libevent_openssl-*so* %{buildroot}%{installpath}/lib
    # cd ..
    mkdir -p $out/{bin,bin/arch/linux,state,etc}
    cp bin/{ATLAS,common-pre.sh,common.sh,reginit.sh,*.lib.sh} $out/bin
    cp bin/arch/linux/* $out/bin/arch/linux
    cp atlas-config/state/* $out/state
    cp atlas-config/etc/* $out/etc
  '';
}
