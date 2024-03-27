{ ansible
, python3Packages
}:

ansible.overrideAttrs (a: {
  pname = "ansible-mgit";
  # add missing hcloud dependency to ansible
  propagatedBuildInputs = a.propagatedBuildInputs ++ (with python3Packages; [
    hcloud
  ]);
})
