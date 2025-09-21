{ inputs, lib, ... }: with lib; {
  imports = [
    # initial lxd
    "${inputs.nixpkgs}/nixos/maintainers/scripts/incus/incus-container-image.nix"
  ];

  # to ease deployment
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PermitEmptyPasswords = mkForce true;
  };

  security.pam.services.sshd.allowNullPassword = true;
}
