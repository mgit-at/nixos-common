{ ansible
, python3
, python3Packages
}:

let
  extraPy = ps: with ps; [
    hcloud
    cryptography
    pyopenssl
  ];
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
