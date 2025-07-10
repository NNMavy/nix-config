{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;

  users.users.mavy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      git
      ssh-to-age
    ];
    # TODO: Move this to a secret
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ/Tn0MifZtxPMhWpPtRzjXMeHKcFAYXvGKMuhPRbRxST8e2JQZ8j/5uCDRh8jXI4EYCZGtgHemuekiAsJBUvWpDImUGqySSot6gWkDnAlyEt2GUDdWByqjI6hlIXXrxqk6SSI8WCU7NnyIJj9INBK3+2dKr6pkoz3Eoneo7qfryxI8IOPFJeTFEOt2+8FPew3PtAwDeydR29/kIjGMXlidZC2w0ILmGjkkbYpgVMTUKIRBmsTjLy4wMp7Dr7H88DhJbLVC4fwv/LNlXoUOoFkYTNj/reT1OtBPZurmIQ6/28xPDFBmFZ++yVfQMrur/F9Z70dX3hYm+IOOZIC0hxL \"NNHome 1Password\""
    ];
  };
  networking.hostId = "bce6d044";
  system.stateVersion = "23.11";
}
