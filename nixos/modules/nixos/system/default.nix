{
  imports = [
    ./openssh.nix
    ./time.nix
    ./security.nix
    ./systempackages.nix
    ./nix.nix
    ./no-graphics-packages.nix
    ./zfs.nix
    ./impermanence.nix
    ./autoupgrades
    ./motd
    ./nfs
    ./telegram
  ];
}
