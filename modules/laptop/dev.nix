{ config, pkgs, lib, ... }: with lib; {
  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    nodejs
    # todo: add everything
  ];
}
