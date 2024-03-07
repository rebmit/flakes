{
  archlinuxcn,
  lib,
  telegram-desktop,
  fetchpatch,
}:
telegram-desktop.overrideAttrs (o: {
  pname = "telegram-desktop-megumifox";
  postPatch = ''
    patch --verbose -b -d Telegram/lib_ui/ -Np1 -i ${archlinuxcn.src}/archlinuxcn/telegram-desktop-megumifox/0001-Use-font-from-environment-variables.patch
  '';
})
