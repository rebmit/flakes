{ config, ... }:
let
  cfg = config.custom.services.desktopEnvironment.sway;
in
{
  wayland.windowManager.sway.config = {
    assigns = {
      "1" = [ (cfg.terminal.windowCriteria) ];
      "2" = [ (cfg.browser.windowCriteria) ];
    };
  };
}
