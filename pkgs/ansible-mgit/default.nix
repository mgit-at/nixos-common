{ callPackage, ansible }:

(callPackage ./package.nix {}) // {
  mkCustom = { extraAnsiblePy, ansible ? ansible }: callPackage ./package.nix { inherit extraAnsiblePy ansible; };
}
