{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "tridentctl";
  version = "22.07.0";

  src = fetchurl {
    url = "https://github.com/NetApp/trident/releases/download/v${version}/trident-installer-${version}.tar.gz";
    hash = "sha256-5rPqSj+Ue0K5HDLfi5zAKH1nVqNkaI6h3bNcwkQznTc=";
  };

  dontBuild = true;

  installPhase = ''
    install -D tridentctl $out/bin/tridentctl
  '';

  meta = with lib; {
    description = "Storage orchestrator for containers - Control binary";
    homepage = "https://github.com/NetApp/trident/";
    changelog = "https://github.com/NetApp/trident/blob/v${src.version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ mkg20001 ];
    mainProgram = "tridentctl";
  };
}
