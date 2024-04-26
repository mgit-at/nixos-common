{ callPackage }:

(callPackage ./package.nix {}) // {
  mkCustom = extraAnsiblePy: callPackage ./package.nix { inherit extraAnsiblePy; };
}
