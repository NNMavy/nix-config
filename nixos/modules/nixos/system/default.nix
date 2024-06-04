{
  imports = [
    ./openssh.nix
    ./time.nix
    ./security.nix
    ./systempackages.nix
    ./nix.nix
    ./zfs.nix
    ./impermanence.nix
    ./autoupgrades
    ./motd
    ./nfs
    ./telegram
  ];
}
