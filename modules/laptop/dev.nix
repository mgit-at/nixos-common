{ config, pkgs, lib, ... }: with lib; {
  imports = [
    ./base.nix
  ];

  environment.shellAliases."bazel" = "bazelisk-env";

  environment.systemPackages = with pkgs; [
    nodejs
    gops
    bazelisk-env
    # todo: add everything
  ];
}
