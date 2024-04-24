{ lib, ... }: with lib; {
  options.mgit.nginx = {
    defaultEmptyHost = mkEnableOption "default empty host" // { default = true; };
  };
}
