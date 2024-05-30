{
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "uas"
        "sd_mod"
      ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.amd.updateMicrocode = true;
}
