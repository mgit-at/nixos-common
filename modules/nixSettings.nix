{ options, lib, ... }@args:
import ./defaults/_with_unify.nix args true
{
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 14d";
}
{
  nix-unify = {
    modules.shareSystemd.units = [ "nix-gc.timer" ];
  };
}
