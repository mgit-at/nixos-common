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
    # include no more than this
    # crt1.o is already taken care of by buildFHSEnv.nix
    gcc_multi.out

    binutils
    pkg-config
    python3
    coreutils-full # is not multi since takes forever to build and no cache available
    bazelisk
    git
    which
    python3
    patch

    # debugging
    iputils
    host
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
