# nix-unify config to share only path
{ lib, pkgs, modulesPath, ... }:

with lib;

{
  imports = [
    ./base-tools.nix
    "${modulesPath}/profiles/minimal.nix"
  ];

  nix-unify.modules = {
    mergePath.enable = true;

    useNixDaemon.enable = false;
    shareUsers.enable = false;
    shareSystemd.enable = false;
  };

  system.disableInstallerTools = false;
  nix.enable = false;

  documentation.man.enable = true;

  system.extraSystemBuilderCmds = ''
    set -x
    etcorig=$(readlink -f $out/etc)
    mv $out/etc $out/_etc
    for f in $out/_etc/systemd/system/nix-unify-at-boot.service $out/_etc/systemd/system/basic.target.wants/nix-unify-at-boot.service; do
      target=$(readlink $f)
      dest=''${f/"_etc"/"etc"}
      mkdir -p $(dirname "$dest")
      ln -s "$target" "$dest"
    done
    rm -f $out/_etc
    find $out -type f -exec sed -i \
      -e s,$etcorig,$out/etc,g \
      {} +
    for f in activate dry-activate prepare-root init systemd; do
      rm -f $out/$f
      ln -sf /dev/null $out/$f
    done
  '';
}
