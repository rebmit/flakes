{
  boot = {
    initrd = {
      kernelModules = [
        "amdgpu"
      ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "uas"
        "sd_mod"
      ];
    };
    kernelModules = ["kvm-amd"];
  };

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.amd.updateMicrocode = true;
}
