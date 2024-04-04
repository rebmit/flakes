{ config, lib, ... }:
with lib; let
  cfg = config.custom.programs.firefox;
in
{
  options.custom.programs.firefox = {
    enable = mkEnableOption "firefox web browser";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        PasswordManagerEnabled = false;
        DisableTelemetry = true;
        DisablePocket = true;
        DisableAccounts = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Preferences = {
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.urlbar.autoFill.adaptiveHistory.enabled" = true;
          "browser.tabs.closeWindowWithLastTab" = false;
          "media.peerconnection.enabled" = false;
          "dom.webnotifications.enabled" = false;
          "dom.webnotifications.serviceworker.enabled" = false;
          "dom.pushconnection.enabled" = false;
          "dom.push.enabled" = false;
        };
        ExtensionSettings = {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          };
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          };
        };
      };
    };
  };
}
