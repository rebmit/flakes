{ source, stdenv, lib }:
stdenv.mkDerivation {
  pname = "metacubexd";

  inherit (source) version src;

  installPhase = ''
    cd ..
    find . -type f -exec install -Dm 644 {} "$out/"{} \;
  '';

  meta = with lib; {
    description = "Mihomo Dashboard";
    homepage = "https://github.com/MetaCubeX/metacubexd";
    license = licenses.mit;
  };
}
