{ config, lib, ... }:

with lib;
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = mkDefault "without-password";
      PubkeyAuthentication = true;
      IgnoreRhosts = true;
      HostbasedAuthentication = false;
      PermitEmptyPasswords = false;
      UseDns = false;
      # disabling this breaks ssh login under nixos
      UsePAM = true;
    };

    # disable ~/.ssh/authorized_keys (default in 24.11)
    authorizedKeysInHomedir = false;

    # https://gitlab.com/gitlab-org/gitlab-foss/-/blob/master/doc/user/gitlab_com/index.md#ssh-host-keys-fingerprints
    knownHosts."gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    # https://github.blog/2021-09-01-improving-git-protocol-security-github/#new-host-keys
    knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };
}
