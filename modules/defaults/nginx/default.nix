{ options, config, lib, ... }@args: with lib;
import ../_with_unify.nix args config.services.nginx.enable
{
  services.nginx = {
    enableReload = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    # Default block returns null for SSL requests with the wrong hostname
    # This is to prevent SNI info leak. This configuration only works for nginx 1.19.4 and later.
    virtualHosts."default" = mkIf (config.mgit.nginx.defaultEmptyHost) {
      default = true;
      listen = [
        { port = 443; ssl = true; addr = "[::]"; }
        { port = 80; addr = "[::]"; }
        { port = 443; ssl = true; addr = "0.0.0.0"; }
        { port = 80; addr = "0.0.0.0"; }
      ];
      extraConfig = ''
        ssl_reject_handshake on;
      '';
      locations."/".extraConfig = ''
        return 404 "This domain is not configured on this server. Please contact your administrator if this seems wrong.";
      '';
    };

  };

  environment.etc."nginx/conf.d".source = ./conf.d;
  environment.etc."nginx/snippets".source = ./snippets;
}
{
  nix-unify = {
    modules.shareSystemd.units = [ "nginx.service" ];
    files.etc."nginx" = {};
  };
}
