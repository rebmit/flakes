{ config, lib, mysecrets, myvars, ... }:
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

    networking = {
      domain = "link.rebmit.moe";
    };

    networking.nftables = {
      enable = true;
      tables = {
        blockBogon4 = {
          family = "ip";
          content = ''
            define bogon = {${lib.concatStringsSep "," myvars.constants.bogonAddresses.ipv4}}

            chain mangle {
              type filter hook prerouting priority mangle; policy accept;
              iifname "en*" ip daddr $bogon counter drop
              iifname "eth*" ip daddr $bogon counter drop
              iifname "ens*" ip daddr $bogon counter drop
            }
          '';
        };
        blockBogon6 = {
          family = "ip6";
          content = ''
            define bogon = {${lib.concatStringsSep "," myvars.constants.bogonAddresses.ipv6}}

            chain mangle {
              type filter hook prerouting priority mangle; policy accept;
              iifname "en*" ip6 daddr $bogon counter drop
              iifname "eth*" ip6 daddr $bogon counter drop
              iifname "ens*" ip6 daddr $bogon counter drop
            }
          '';
        };
      };
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
