{ config, lib, mysecrets, ... }:
let
  cfg = config.custom.cloud.common;
in
with lib; {
  options.custom.cloud.common = {
    enable = mkEnableOption "common preset";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 2222 ];
      settings.PasswordAuthentication = false;
    };

    users.users.root.openssh.authorizedKeys.keys = mysecrets.sshPublicKeys;

    services.caddy.enable = true;

    environment.persistence."/persist" = {
      files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
          "9p"
          "9pnet_virtio"
        ];
        kernelModules = [
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
        ];
        postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable)
          ''
            # Set the system time from the hardware clock to work around a
            # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
            # to the *boot time* of the host).
            hwclock -s
          '';
      };
    };
  };
}
