{ options, config, lib, ... }: with lib; mkIf (config.services.nginx.enable) {
  services.nginx = {
    enableReload = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
  };

  nix-unify = mkIf (options ? "nix-unify") {
    modules.shareSystemd.units = [ "nginx.service" ];
    files.etc."nginx" = {};
  };
}
