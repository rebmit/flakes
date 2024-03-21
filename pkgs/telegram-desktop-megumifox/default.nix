{ source, telegram-desktop }:
telegram-desktop.overrideAttrs (o: {
  pname = "telegram-desktop-megumifox";
  postPatch = ''
    patch --verbose -b -d Telegram/lib_ui/ -Np1 -i ${source.src}
  '';
})
