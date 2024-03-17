{ options, config, lib, ... }@args:
import ./_with_unify.nix args config.services.nginx.enable
{
  services.nginx = {
    enableReload = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
  };
}
{
  nix-unify = {
    modules.shareSystemd.units = [ "nginx.service" ];
    files.etc."nginx" = {};
  };
}
