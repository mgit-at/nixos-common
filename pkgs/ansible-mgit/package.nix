{ ansible
, python3
, python3Packages
, extraAnsiblePy ? []
}:

let
  extraPy = ps: with ps; [
    hcloud
    cryptography
    pyopenssl
    jmespath
    pyyaml
    kubernetes
    jsonpatch
  ] ++ (builtins.map (name: ps.${name}) extraAnsiblePy);

  py = python3.withPackages extraPy;
in
ansible.overrideAttrs (a: {
  name = "${a.name}-MGIT";
  # add missing hcloud dependency to ansible
  propagatedBuildInputs = a.propagatedBuildInputs ++ (extraPy python3Packages);

  preFixup = ''
    makeWrapperArgs+=(--prefix PYTHONPATH : "${py}/${py.sitePackages}")
  '';
})
