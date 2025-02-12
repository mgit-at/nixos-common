{ callPackage, ansible, ansible_2_17, ansible_2_16 }:

(callPackage ./package.nix {}) // {
  mkCustom = { extraAnsiblePy, ansible ? ansible }: callPackage ./package.nix { inherit extraAnsiblePy ansible; };
  v2_17 = callPackage ./package.nix { ansible = ansible_2_17; };
  v2_16 = callPackage ./package.nix { ansible = ansible_2_16; };
}
