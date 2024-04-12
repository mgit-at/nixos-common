{ stdenv
, lib
, gawk
, findutils
, ethtool
}:

stdenv.mkDerivation {
  name = "ethtool-setringmax";
  src = ./src;

  buildInputs = [
    gawk
    ethtool
  ];

  buildPhase = ''
    substituteInPlace ethtool-setringmax \
      --subst-var-by find ${findutils}/bin/find \
      --subst-var-by ethtool ${ethtool}/bin/ethtool \
      --subst-var-by out ${placeholder "out"}

    substituteInPlace ethtool-setringmax.awk \
      --subst-var-by ethtool ${ethtool}/bin/ethtool

    patchShebangs ethtool-setringmax.awk
  '';

  installPhase = ''
    install -D ethtool-setringmax $out/bin/ethtool-setringmax
    install -D ethtool-setringmax.awk $out/libexec/ethtool-setringmax.awk
  '';

  meta = {
    mainProgram = "ethtool-setringmax";
    maintainers = with lib.maintainers; [ mkg20001 ];
  };
}
