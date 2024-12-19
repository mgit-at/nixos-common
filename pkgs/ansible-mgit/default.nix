{ callPackage, ansible, ansible_2_16, ansible_2_15 }:

(callPackage ./package.nix {}) // {
  mkCustom = { extraAnsiblePy, ansible ? ansible }: callPackage ./package.nix { inherit extraAnsiblePy ansible; };
  v2_16 = callPackage ./package.nix { ansible = ansible_2_16; };
  v2_15 = callPackage ./package.nix { ansible = ansible_2_15; };
}
