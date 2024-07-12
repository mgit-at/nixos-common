disko: { inputs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    disko.nixosModules.disko
    ./disko.nix
    ({
      _module.args.disks = [ "/dev/sda" ];
    })
  ];

  # boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  boot.tmp.cleanOnBoot = true;
  boot.growPartition = true;
}
