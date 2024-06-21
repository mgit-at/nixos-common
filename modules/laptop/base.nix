{ config, pkgs, lib, ... }: with lib; {
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    package = pkgs.nixVersions.latest;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}