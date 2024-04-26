final: prev:
  (prev.lib.mapAttrs (pkg: _: prev.callPackage "${./pkgs}/${pkg}" {}) (builtins.readDir ./pkgs)) // {
    mkAnsibleDevShell = { extraAnsiblePy ? [], packages ? [], ... }@args: final.mkShell (args // {
      packages = with final; packages ++ [
        (ansible-mgit.mkCustom extraAnsiblePy)
        age
      ];
    });
  }
