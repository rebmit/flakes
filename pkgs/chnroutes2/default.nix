{ source, stdenv, lib }:
stdenv.mkDerivation {
  pname = "chnroutes2";

  inherit (source) version src;

  buildPhase = ''
    echo "define chnroutes2 = {" >  chnroutes.nft
    awk '{printf "%s  %s",sep,$0; sep=",\n"} END{print ""}' chnroutes.txt >> chnroutes.nft
    echo "}" >> chnroutes.nft
  '';

  installPhase = ''
    install -Dm644 "chnroutes.mmdb" "$out/chnroutes.mmdb"
    install -Dm644 "chnroutes.txt"  "$out/chnroutes.txt"
    install -Dm644 "chnroutes.nft"  "$out/chnroutes.nft"
  '';

  meta = with lib; {
    description = "Better aggregated chnroutes";
    homepage = "https://github.com/misakaio/chnroutes2";
    license = licenses.cc-by-sa-40;
  };
}
