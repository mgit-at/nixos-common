let
  self = {
    devops = import ./devops.nix;
    dev = import ./dev.nix;
  };
in
{
  all = {
    imports = builtins.attrValues self;
  };
} // self
