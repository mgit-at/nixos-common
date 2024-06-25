{ config, pkgs, lib, ... }: with lib; {
  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    nodejs
    gops
    # todo: add everything
  ];
}
