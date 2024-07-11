final: prev:
  let
    args = {
      prometheus-node-exporter = {
        inherit (prev.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
      };
    };
  in
  (prev.lib.mapAttrs (pkg: _: prev.callPackage "${./pkgs}/${pkg}" (if args ? pkg then args.${pkg} else {})) (builtins.readDir ./pkgs)) // {
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
