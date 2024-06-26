{ source, stdenv, lib, ipv6 ? false }:
with lib;
stdenv.mkDerivation {
  pname = "smartdns-china-list";

  inherit (source) version src;

  buildPhase = ''
    make SERVER=domestic SMARTDNS_SPEEDTEST_MODE=tcp:80 smartdns-domain-rules
    ${optionalString (!ipv6) ''
      sed -i "s/\$/ -address #6/g" accelerated-domains.china.domain.smartdns.conf
      sed -i "s/\$/ -address #6/g" apple.china.domain.smartdns.conf
      sed -i "s/\$/ -address #6/g" google.china.domain.smartdns.conf
    ''}
  '';

  installPhase = ''
    install -Dm644 "accelerated-domains.china.domain.smartdns.conf" "$out/accelerated-domains.china.domain.smartdns.conf"
    install -Dm644 "apple.china.domain.smartdns.conf" "$out/apple.china.domain.smartdns.conf"
    install -Dm644 "google.china.domain.smartdns.conf" "$out/google.china.domain.smartdns.conf"
  '';

  meta = with lib; {
    description = "Chinese-specific configuration to improve your favorite DNS server. Best partner for chnroutes.";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = licenses.wtfpl;
  };
}
