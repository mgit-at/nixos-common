{ ansible
, python3Packages
}:

ansible.overrideAttrs (a: {
  name = "${a.name}-MGIT";
  # add missing hcloud dependency to ansible
  propagatedBuildInputs = a.propagatedBuildInputs ++ (with python3Packages; [
    hcloud
    cryptography
  ]);
})
