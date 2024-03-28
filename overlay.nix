final: prev:
  (prev.lib.mapAttrs (pkg: _: prev.callPackage "${./pkgs}/${pkg}" {}) (builtins.readDir ./pkgs)) // {
    mkAnsibleDevShell = { packages ? [], ... }@args: final.mkShell args // {
      packages = with final; packages ++ [
        ansible-mgit
        age
      ];
    };
  }
