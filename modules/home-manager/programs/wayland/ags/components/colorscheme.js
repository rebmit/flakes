import Gio from "gi://Gio";
import GLib from "gi://GLib";

import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import { exec, execAsync } from "resource:///com/github/Aylur/ags/utils.js";

const isDark = (desktopSettings) => {
  return desktopSettings.get_string("color-scheme") == "prefer-dark";
};

const desktopSettings = new Gio.Settings({
  schema_id: "org.gnome.desktop.interface",
});

const dark = Variable(isDark(desktopSettings));

desktopSettings.connect("changed::color-scheme", () => {
  dark.value = isDark(desktopSettings);
});

export const ColorScheme = () =>
  Widget.Button({
    className: "colorscheme",
    onClicked: () => {
      execAsync(["toggle-theme"]);
    },
    child: Widget.Box({
      spacing: 10,
      children: [
        Widget.Label({
          connections: [
            [dark, (self) => (self.label = dark.value ? "" : "")],
          ],
        }),
      ],
    }),
  });
