{ config, pkgs, lib, inputs, modulesPath, ... }: {
  imports =
    [
      ../incus/configuration.nix
    ];

  environment.systemPackages = with pkgs; [
    git
    bazelisk-env
  ];

  networking.hostName = "bazelisk";

  users.users.test = {
    isNormalUser = true;
  };
}
