{ options, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.apt;
  apt = cfg.package;

  apt-mock-packages = pkgs.writeShellScriptBin "apt-mock-packages"
    (builtins.readFile ./apt-mock-packages.sh);
in
{
  options.programs.apt = {
    enable = mkEnableOption "apt cli and DEB package support";

    fakePackages = mkOption {
      default = [];
      description = "Packages to mock as installed in dpkg";
      type = with types; listOf str;
    };

    nixLDPackages = if options.programs ? "nix-ld"
      then options.programs.nix-ld.libraries
      else mkOption { type = types.listOf types.str; default = []; };

    package = lib.mkPackageOption pkgs "apt" { };
  };

  config = mkIf (cfg.enable) {
    programs.apt.fakePackages = [
      # our stuff
      "apt"
      "dpkg"

      # see nix-ld defaults at
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/nix-ld.nix#L42
      # zlib
      "zlib1g"
      # zstd
      "libzstd1"
      # stdenv.cc.cc
      "libc6"
      # curl
      "curl"
      # openssl
      "openssl"
      # attr
      "libattr1"
      # libssh
      "libssh2-1"
      # bzip2
      "bzip2"
      # libxml2
      "libxml2"
      # acl
      "libacl1"
      # libsodium
      "libsodium23"
      # util-linux
      "util-linux"
      # xz
      "xz-utils"
      # systemd
      "libsystemd-shared"
      "libsystemd0"

      # other defaults
      "sudo"
      "mount"
      "passwd"
      "base-files"
      "base-passwd"
    ];

    environment.systemPackages = [
      pkgs.dpkg
      apt
      pkgs.gnupg
      apt-mock-packages
    ];

    systemd.services.apt-setup = {
      script = ''
        if [ ! -e /etc/apt ]; then
          cp -rp ${apt}/ETC_APT_TEMPLATE /etc/apt
          chmod +w -R /etc/apt
        fi
        if [ ! -e /var/lib/apt ]; then
          mkdir -p /var/lib
          cp -rp ${apt}/VAR_LIB_APT_TEMPLATE /var/lib/apt
          chmod +w -R /var/lib/apt
        fi
        if [ ! -e /var/cache/apt ]; then
          mkdir -p /var/cache
          cp -rp ${apt}/VAR_CACHE_APT_TEMPLATE /var/cache/apt
          chmod +w -R /var/cache/apt
        fi
        if [ ! -e /var/log/apt ]; then
          mkdir -p /var/log
          cp -rp ${apt}/VAR_LOG_APT_TEMPLATE /var/log/apt
          chmod +w -R /var/log/apt
        fi
        mkdir -p /var/lib/dpkg
        mkdir -p /usr/share/keyrings
        ${apt-mock-packages}/bin/apt-mock-packages ${escapeShellArgs cfg.fakePackages}
      '';
      wantedBy = [ "multi-user.target" "default.target" ];
      serviceConfig = {
        RemainAfterExit = true;
      };
    };

    programs.nix-ld = {
      enable = true;
      libraries = cfg.nixLDPackages;
    };
  };
}
