{
  lib,
  telegram-desktop,
  fetchpatch,
}:
telegram-desktop.overrideAttrs (o: {
  pname = "telegram-desktop-megumifox";
  postPatch = ''
    patch --verbose -b -d Telegram/lib_ui/ -Np1 -i ${fetchpatch {
      name = "use-font-from-environment-variables.patch";
      url = "https://raw.githubusercontent.com/archlinuxcn/repo/6cd7ce54271abdd47852cb74808eff9423a27d37/archlinuxcn/telegram-desktop-megumifox/0001-Use-font-from-environment-variables.patch";
      sha256 = "sha256-zl78Ck4RA4vtzpqeDW2sdRdZxT15tWrk/5BL/OLYLb4=";
    }}
  '';
  meta.platforms = ["x86_64-linux"];
})
