final: prev:
  (prev.lib.mapAttrs (pkg: _: prev.callPackage "${./pkgs}/${pkg}" {}) (builtins.readDir ./pkgs))
