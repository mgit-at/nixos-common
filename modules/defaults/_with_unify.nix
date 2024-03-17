{ options, lib, ... }: cond: opt: unifyopt:

with lib;

mkIf (cond) (mkMerge [
  opt
  (if options ? "nix-unify" then unifyopt else {})
])
