{ config, lib, modulesPath, ... }:
{
  # Placeholder hardware profile for Apple Silicon laptops (Asahi).
  # Regenerate this file with `nixos-generate-config` on the target device
  # to capture disk layout and kernel module preferences.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "uas"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = lib.mkDefault [ ];
}
