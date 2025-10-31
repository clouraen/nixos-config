{ config, lib, modulesPath, ... }:
{
  # Baseline virtualised Apple Silicon profile. Adapt the filesystem stanza
  # with `nixos-generate-config` for your UTM/Virtualization framework image.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
    "virtio_net"
    "uas"
    "usb_storage"
  ];
  boot.kernelModules = [ "virtio_gpu" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = lib.mkDefault [ ];
}
