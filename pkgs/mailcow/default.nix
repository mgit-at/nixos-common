{ stdenv
, which
, openssl
, bash
, oils-for-unix
, initool
, diffutils
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
, findutils
, jq
}:

let
  pathPkgs = [
    # script
    initool
    diffutils
    # mailcow
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
    findutils
    jq
    iproute2
  ];
  path = lib.makeBinPath pathPkgs;
in
stdenv.mkDerivation {
  name = "mailcow";

  src = ./src;

  buildInputs = [
    oils-for-unix
  ];

  buildPhase = ''
    substituteInPlace bin.sh \
      --subst-var-by path "${path}"
  '';

  installPhase = ''
    install -m 755 -D bin.sh $out/bin/mailcow
    ln -s $out/bin/mailcow $out/bin/mailcow-shell
  '';
}
