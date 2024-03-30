{ stdenv
, which
, openssl
, bash
, coreutils
, curl
, wget
, docker
, git
, gawk
, gnugrep
, gnused
, iptables-nftables-compat
, lib
}:

let
  pathPkgs = [
    which
    openssl
    bash
    coreutils
    curl
    wget
    docker # config.virtualisation.docker.package
    git
    gawk
    gnugrep
    gnused
    iptables-nftables-compat
  ];
  path = lib.makeBinPath pathPkgs;
in
stdenv.mkDerivation {
  name = "mailcow";

  src = ./src;

  buildPhase = ''
    substituteInPlace bin.sh \
      --subst-var-by path "${path}"
  '';

  installPhase = ''
    install -m 755 -D bin.sh $out/bin/mailcow
    ln -s $out/bin/mailcow $out/bin/mailcow-shell
  '';
}
