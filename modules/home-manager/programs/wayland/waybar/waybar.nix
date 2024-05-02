{ pkgs, config }: {
  height = 36;
  layer = "top";
  "custom/nixos" = {
    format = "";
    interval = "once";
    tooltip = false;
  };
  modules-left = [
    "custom/nixos"
    "sway/workspaces"
    "sway/mode"
  ];
  modules-right = [
    "sway/window"
    "idle_inhibitor"
    "pulseaudio"
    "memory"
    "temperature"
    "clock"
    "tray"
  ];
  "sway/workspaces" = {
    all-outputs = true;
    format = "{name}";
  };
  "sway/window" = {
    format = "{}";
    all-outputs = true;
    max-length = 60;
    offscreen-css = true;
    offscreen-css-text = "(inactive)";
  };
  idle_inhibitor = {
    format = "{icon} ";
    format-icons = {
      activated = "";
      deactivated = "";
    };
  };
  pulseaudio = {
    format = "{icon} {volume}% {format_source}";
    format-bluetooth = "󰂯 {volume}% {format_source}";
    format-bluetooth-muted = "󰝟 {volume}% {format_source}";
    format-icons = {
      headphone = "󰋋";
      default = [ "󰖀" "󰕾" ];
    };
    format-muted = "󰝟 {volume}% {format_source}";
    format-source = " {volume}%";
    format-source-muted = " {volume}%";
    on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
  };
  clock = {
    format = "{:%a %b %d %H:%M}";
  };
  memory = {
    format = " {percentage}%";
  };
  temperature = {
    format = " {temperatureC}°C";
    interval = 10;
    thermal-zone = 2;
    hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
  };
  tray = {
    icon-size = 18;
    spacing = 10;
  };
}
