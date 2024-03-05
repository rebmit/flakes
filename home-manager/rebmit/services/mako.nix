{
  config,
  pkgs,
  ...
}: {
  services.mako = {
    enable = true;
    package = pkgs.mako;
    extraConfig = ''
      background-color=#${config.colorScheme.palette.base00}
      text-color=#${config.colorScheme.palette.base05}
      border-color=#${config.colorScheme.palette.base0D}
      [urgency=low]
      border-color=#${config.colorScheme.palette.base0D}
      [urgency=normal]
      border-color=#${config.colorScheme.palette.base0D}
      [urgency=high]
      border-color=#${config.colorScheme.palette.base08}
    '';
  };
}
