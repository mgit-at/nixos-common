{ config, pkgs, lib, ... }: with lib; {
  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    ansible-mgit
    ansible-vault-tools
    age
    pre-commit

    k9s
    kind
    kn
    krew
    kubectl
    kubernetes-helm
    minio-client
    websocat
    rustscan
    sniffglue
  ];

  programs.git.config = {
    push = { autoSetupRemote = true; };
    "diff \"ansible-vault\"" = {
      textconv = "ansible-vault view";
      cachetextconv = false;
    };
    "merge \"ansible-vault\"" = {
      name = "ansible-vault merge driver";
      driver = "ansible-vault-merge -- %O %A %B %P";
    };
  };

  nix = {
    settings = {
      # In general, outputs must be registered as roots separately. However, even if the output of a derivation is registered as a root, the collector will still delete store paths that are used only at build time (e.g., the C compiler, or source tarballs downloaded from the network). To prevent it from doing so, set this option to true.
      gc-keep-outputs = true;
      gc-keep-derivations = true;
      env-keep-derivations = true;
      # Cache TTLs (todo: option mgit.skip-nix-cache = true;)
      # narinfo-cache-positive-ttl = 0;
      # narinfo-cache-negative-ttl = 0;
    };
  };
}
