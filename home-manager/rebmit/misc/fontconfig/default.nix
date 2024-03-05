{pkgs, ...}: {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    roboto-mono
    (nerdfonts.override {fonts = ["RobotoMono"];})
  ];

  xdg.configFile."fontconfig/fonts.conf".source = ./fonts.conf;

  fonts.fontconfig.enable = true;
}
