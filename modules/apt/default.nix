{ options, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.apt;
  apt = pkgs.callPackage ./apt-patched.nix {};
in
{
  options.programs.apt = {
    enable = mkEnableOption "apt cli and DEB package support";

    fakePackages = mkOption {
      default = [];
      description = "Packages to mock as installed in dpkg";
      type = with types; listOf str;
    };

    nixLDPackages = options.programs.nix-ld.libraries;
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [
      apt
      pkgs.gnupg
    ];

    system.activationScripts.apt.text = ''
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
    '';

    programs.nix-ld = {
      enable = true;
      libraries = cfg.nixLDPackages;
    };
  };
}
