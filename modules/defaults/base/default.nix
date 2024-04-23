# This is seperate so we have 1:1 what we have in ansible base role in here

{
  imports = [
    ./exporters.nix
    ./modules.nix
    ./resolved.nix
    ./screen.nix
    ./sshd.nix
    ./sysctl.nix
  ];
}
