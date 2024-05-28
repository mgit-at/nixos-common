{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "tridentctl";
  version = "24.02.0";

  src = fetchurl {
    url = "https://github.com/NetApp/trident/releases/download/v${version}/trident-installer-${version}.tar.gz";
    hash = "sha256-4vnmdi6JZ+pJ9mpujz7ehl/fnbPI6ss+DVLq9a/HhnM=";
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
