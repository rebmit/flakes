{
  config,
  pkgs,
  ...
}: {
  programs.fuzzel = {
    enable = true;
    package = pkgs.fuzzel;
    settings = {
      main = {
        font = "monospace";
        terminal = "${pkgs.kitty}/bin/kitty -e";
        layer = "overlay";
      };
      colors = {
        background = "${config.colorScheme.palette.base00}ee";
        text = "${config.colorScheme.palette.base05}ff";
        match = "${config.colorScheme.palette.base0D}ff";
        selection = "${config.colorScheme.palette.base04}ff";
        selection-text = "${config.colorScheme.palette.base05}ff";
        selection-match = "${config.colorScheme.palette.base0D}ff";
        border = "${config.colorScheme.palette.base0D}ff";
      };
      border = {
        width = "2";
        radius = "0";
      };
    };
  };
}
