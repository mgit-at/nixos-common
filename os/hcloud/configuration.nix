disko: { inputs, modulesPath, config, lib, ... }: with lib;
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    disko.nixosModules.disko
    ./disko.nix
    ({
      _module.args.disks = [ "/dev/sda" ];
    })
  ];

  options = {
    mgit.hcloud.auto-network = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Hetzner cloud network autosetup. Specifiy IPv6 address here to enable.";
    };
  };

  config = mkMerge [
    {
      # boot.loader.grub.device = "/dev/sda";
      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
      boot.initrd.kernelModules = [ "nvme" ];

      boot.tmp.cleanOnBoot = true;
      boot.growPartition = true;
    }
    (mkIf (config.mgit.hcloud.auto-network != null) {
      networking.usePredictableInterfaceNames = false;

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "ipv4";
        address = [
          "${config.mgit.hcloud.auto-network}"
        ];
        routes = [
          { routeConfig.Gateway = "fe80::1"; }
        ];
      };
    })
  ];
}
