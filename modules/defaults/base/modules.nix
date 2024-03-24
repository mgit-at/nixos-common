{ config, pkgs, lib, ... }:

with lib;

let
  net = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
  ];
  fs = [
    "cramfs"
    "freevxfs"
    "hfs"
    "hfsplus"
    "jffs2"
  ];
  misc = [
    "bluetooth"
    "firewire-core"
    "n_hdlc"
    "net-pf-31"
    "soundcore"
    "thunderbolt"
    "usb-midi"
  ];
in
{
  environment.etc."modprobe.d/disablemod.conf".text = concatStringsSep "\n"
    (map (module: "install ${module} ${pkgs.coreutils}/bin/true")
      (net ++ fs ++ misc)
    );
}
