# nix-unify config to share only path
{
  imports = [
    ./base-tools.nix
  ];

  nix-unify.modules = {
    mergePath.enable = true;

    useNixDaemon.enable = false;
    shareUsers.enable = false;
    shareSystemd.enable = false;
  };
}
