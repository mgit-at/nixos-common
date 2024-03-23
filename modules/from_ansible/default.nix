{ config, lib, ... }:

with lib;

{
  users.users.root.openssh.authorizedKeys.keys =
    mkIf (config.ansible.hostvars ? "base_ssh_root_keys")
      config.ansible.hostvars.base_ssh_root_keys;

  services.openssh.settings.AllowUsers =
    mkIf (config.ansible.hostvars ? "base_ssh_allow_users")
      (lib.concatStringsSep " " config.ansible.hostvars.base_ssh_allow_users);
}
