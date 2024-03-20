# This is seperate so we have 1:1 what we have in ansible in here

{
  imports = [
    ./screen.nix
    ./sshd.nix
    ./sysctl.nix
  ];
}
