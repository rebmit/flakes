# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  dnsmasq-china-list = {
    pname = "dnsmasq-china-list";
    version = "ebfbdb1d6894a79fe1a248e43b3619768168615d";
    src = fetchFromGitHub {
      owner = "felixonmars";
      repo = "dnsmasq-china-list";
      rev = "ebfbdb1d6894a79fe1a248e43b3619768168615d";
      fetchSubmodules = false;
      sha256 = "sha256-N+p9qAbu6ZwV5lFm6qNTioQ837pFGibYoMdPVmI21nw=";
    };
    date = "2024-03-13";
  };
  telegram-desktop-megumifox = {
    pname = "telegram-desktop-megumifox";
    version = "6d1b3cf74f7d4cd92a3577d73456b0b7b7443953";
    src = fetchurl {
      url = "https://raw.githubusercontent.com/archlinuxcn/repo/6d1b3cf74f7d4cd92a3577d73456b0b7b7443953/archlinuxcn/telegram-desktop-megumifox/0001-Use-font-from-environment-variables.patch";
      sha256 = "sha256-IQiyJPbFZ0XSSZbcMYS0J1dej5G5LRx4qB/frW7QtnA=";
    };
    date = "2024-03-15";
  };
}
