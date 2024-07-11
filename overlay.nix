final: prev:
  (prev.lib.mapAttrs (pkg: _: prev.callPackage "${./pkgs}/${pkg}" {}) (builtins.readDir ./pkgs)) // {
    mkAnsibleDevShell = { extraAnsiblePy ? [], packages ? [], shellHook ? "", ... }@args: final.mkShell (args // {
      LOCALE_ARCHIVE = "${final.glibcLocales}/lib/locale/locale-archive";

      packages = with final; packages ++ [
        (ansible-mgit.mkCustom extraAnsiblePy)
        age
        pre-commit
      ];

      shellHook = ''
        export PYTHONPATH=
        ${shellHook}
      '';
    });
  }
