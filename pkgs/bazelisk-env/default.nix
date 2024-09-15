{
  buildFHSUserEnv,
}:

buildFHSUserEnv {
  name = "bazelisk-env";
  extraOutputsToInstall = ["include" "dev"]; # TODO: make it saner?

  # this is necesarry to make sure we don't inherit things from nixos that we don't want to inherit
  # like non-FHS bash interactive from /run/current-system/sw/bin
  extraBwrapArgs = [
    # for debugging
    "--ro-bind" "/run" "/.host-run"

    "--tmpfs" "/run"
    # dns
    "--ro-bind" "/run/systemd" "/run/systemd"
    # several things, including dns
    "--ro-bind" "/run/nscd" "/run/nscd"
  ];

  # for go build
  multiArch = true;

  # NOTE: since /run/current-system is inaccessible
  # EVERY required tool must be specified here
  targetPkgs = pkgs: with pkgs; [
    # include no more than out for gcc and binutils
    # crt1.o is already taken care of by buildFHSEnv.nix
    # it might break things otherwise

    # old approach: this doesn't work as it makes executables use nix ld
    # gcc_multi.out

    # old approach: hack arround the wrapper with sed, doesn't really work
    # (pkgs.callPackage ./gcc_multi_patched.nix {})

    # need to patch in -L/usr/lib -L/usr/lib32 (for libs) -B/usr/lib -B/usr/lib32 (for crt1.o, etc.)
    # this does the trick (disables the patches that remove it by ddefault)
    # theoretically the same could also be achived by wrapping gcc
    # but this is too complex (see current pkgs/build-support/cc-wrapper)
    (let
      gccVanilla = gcc14.cc;
      patches = (gccVanilla.override { noSysDirs = false; }).patches;
    in
      gccVanilla.overrideAttrs {
        # we need to override just the patches, as noSysDirs=false
        # disables some compile-fixing magic
        inherit patches;
      })
    binutils-unwrapped.out # provides ld
    # we don't want to _also_ rebuilt binutils-unwrapped so we just drop in an ld wrapper
    # (this is way simpler than messing with wrapping gcc)
    (hiPrio (writeShellScriptBin "ld" ''
      set -euo pipefail

      # NOTE: building pure 32bit is broken (would need to use expand-params-response and check for 32bit flag).
      # but i don't think we need it.
      flags=("-dynamic-linker=/lib64/ld-linux-x86-64.so.2")

      ${binutils-unwrapped}/bin/ld "''${flags[@]}" "$@" "''${flags[@]}"
    ''))

    pkg-config
    python3
    coreutils-full # is not multi since takes forever to build and no cache available
    bazelisk
    git
    which
    python3
    patch
    curl

    # debugging
    iputils
    host
    (writeShellScriptBin "compile-hello-world" ''
      set -x

      gcc ${writeText "hello-world.c" ''
        #include<stdio.h>

        int main() {
          printf("Hello World from Bazel!\n");
        }
      ''} -o /tmp/hello-world

      ldd /tmp/hello-world
    '')
  ];

  # everything that we need both 64bit and 32bit versions of
  multiPkgs = pkgs: with pkgs; [
    zlib
    # for python3 build
    libxcrypt-legacy
  ];

  profile = ''
    export BAZELISK_ENV=1
    export CC=$(which gcc)

    CMD=bazelisk

    if [ -v USE_SHELL ]; then
      CMD="/usr/bin/bash"
    fi
  '';

  runScript = "$CMD"; # $@ will already be appended by nix
}
