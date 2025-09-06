{ callPackage, ansible, ansible_2_19, ansible_2_18, ansible_2_17, ansible_2_16, ansible_2_15 }:

(callPackage ./package.nix {}) // {
  mkCustom = { extraAnsiblePy, ansible ? ansible }: callPackage ./package.nix { inherit extraAnsiblePy ansible; };
  v2_19 = callPackage ./package.nix { ansible = ansible_2_19; };
  v2_18 = callPackage ./package.nix { ansible = ansible_2_18; };
  v2_17 = callPackage ./package.nix { ansible = ansible_2_17; };
  v2_16 = callPackage ./package.nix { ansible = ansible_2_16; };
  v2_15 = callPackage ./package.nix { ansible = ansible_2_15; };
}
