{ config, ... }:
let
  cfg = config.custom.services.desktopEnvironment.sway;
in
{
  wayland.windowManager.sway.config = {
    assigns = {
      "2" = [ (cfg.browser.windowCriteria) ];
    };
  };
}
