{ config, lib, modulesPath, ... }:
{
  # Placeholder hardware profile for Apple Silicon desktops (Asahi).
  # Replace the filesystem definitions with the output of `nixos-generate-config`
  # after bootstrapping on your target machine.
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
