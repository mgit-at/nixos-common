# This is seperate so we have 1:1 what we have in ansible base role in here

{
  imports = [
    ./modules.nix
    ./screen.nix
    ./sshd.nix
    ./sysctl.nix
  ];
}
