{
  gcc_multi,
  stdenv,
}:

stdenv.mkDerivation {
  name = gcc_multi.name + "-fhs";

  src = gcc_multi;

  buildPhase = ''
    find . -type f -exec sed -i \
      -e s,${gcc_multi.out},$out,g \
      -e s,${gcc_multi.cc.lib},,g \
      -e s,${gcc_multi.libc},,g \
      -e s,${gcc_multi.libc.dev},/usr,g \
      {} +

    find bin -type f -exec sed -i \
      -e 's,expandResponseParams,params=("$@");true,g' \
      {} +
  '';

  installPhase = ''
    cp -rp . $out
  '';
}
