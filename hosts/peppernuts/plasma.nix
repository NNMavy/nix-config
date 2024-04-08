{
  inputs,
  pkgs,
  ...
}: {
  services = {
    fprintd.enable = true;
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
  };

  security.rtkit.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    openssl
    firefox
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      (nerdfonts.override {fonts = ["FiraCode"];})
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["FiraCode Nerd Font"];
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
      };
    };
  };
}
