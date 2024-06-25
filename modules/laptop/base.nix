{ config, pkgs, lib, ... }: with lib; {
  options = {
    mgit = {
      skipNixCache = mkEnableOption "skipping the nix-internal cache when checking the cache";
    };
  };

  config = mkMerge [
    {
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

      virtualisation.docker = {
        enable = true;
        # save resources
        enableOnBoot = false;
        # this causes problems on shutdown
        liveRestore = false;
      };

      environment.systemPackages = with pkgs; [
        ripgrep
        fd
        dua
        yq-go
        open-policy-agent # for evaluating opa policies, also for ansible
      ];
    }
    (mkIf (config.mgit.skipNixCache) {
      nix.settings = {
        # Disable cache
        narinfo-cache-positive-ttl = 0;
        narinfo-cache-negative-ttl = 0;
      };
    })
  ];
}
