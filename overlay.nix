final: prev:
  (prev.lib.mapAttrs (pkg: _: prev.callPackage "${./pkgs}/${pkg}" {}) (builtins.readDir ./pkgs)) // {
    apt_vanilla = prev.apt;
    mkAnsibleDevShell = { ansible ? prev.ansible, extraAnsiblePy ? [], packages ? [], shellHook ? "", ... }@args: final.mkShell (args // {
      LOCALE_ARCHIVE = "${final.glibcLocales}/lib/locale/locale-archive";

      packages = with final; packages ++ [
        (ansible-mgit.mkCustom { inherit extraAnsiblePy ansible; })
        age
        pre-commit
      ];

      shellHook = ''
        export PYTHONPATH=
        ${shellHook}
      '';
    });
  }
