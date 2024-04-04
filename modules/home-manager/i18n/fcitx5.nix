{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.i18n.fcitx5;
  fcitx5Package =
    if cfg.plasma6Support
    then pkgs.qt6Packages.fcitx5-with-addons.override { inherit (cfg) addons withConfigtool; }
    else pkgs.libsForQt5.fcitx5-with-addons.override { inherit (cfg) addons withConfigtool; };
  gtk2Cache = pkgs.runCommandLocal "gtk2-immodule.cache"
    {
      buildInputs = [ pkgs.gtk2 fcitx5Package ];
    } ''
    mkdir -p $out/etc/gtk-2.0/
    GTK_PATH=${fcitx5Package}/lib/gtk-2.0/ \
      gtk-query-immodules-2.0 > $out/etc/gtk-2.0/immodules.cache
  '';
  gtk3Cache = pkgs.runCommandLocal "gtk3-immodule.cache"
    {
      buildInputs = [ pkgs.gtk3 fcitx5Package ];
    } ''
    mkdir -p $out/etc/gtk-3.0/
    GTK_PATH=${fcitx5Package}/lib/gtk-3.0/ \
      gtk-query-immodules-3.0 > $out/etc/gtk-3.0/immodules.cache
  '';
in
{
  options.custom.i18n.fcitx5 = {
    enable = mkEnableOption "input method framework";
    addons = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    kittySupport = mkOption {
      type = types.bool;
      default = false;
    };
    waylandFrontend = mkOption {
      type = types.bool;
      default = false;
    };
    plasma6Support = mkOption {
      type = types.bool;
      default = false;
    };
    withConfigtool = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ fcitx5Package gtk2Cache gtk3Cache ];

    home.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      QT_PLUGIN_PATH = "${fcitx5Package}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    } // lib.optionalAttrs (!cfg.waylandFrontend) {
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
    } // lib.optionalAttrs (cfg.kittySupport) {
      GLFW_IM_MODULE = "ibus";
    };

    systemd.user.services.fcitx5-daemon = {
      Unit = {
        Description = "Fcitx5 input method editor";
        PartOf = [ "graphical-session.target" ];
      };
      Service.ExecStart = "${fcitx5Package}/bin/fcitx5";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
