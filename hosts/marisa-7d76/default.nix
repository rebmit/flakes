{ config, lib, pkgs, mylib, myvars, mysecrets, ... }:
let
  hostName = "marisa-7d76";
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes.${hostName};
in
{
  imports =
    [
      mysecrets.nixosModules.secrets.marisa
    ]
    ++ (mylib.getItemPaths ./. [ "default.nix" "home.nix" ]);

  custom = {
    baseline.enable = true;
    system = {
      boot.secureboot.enable = true;
      disko.btrfs-luks-uefi-common = {
        enable = true;
        device = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
      };
    };
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = lib.mkDefault true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix.settings.trusted-users = [ "root" "rebmit" ];

  i18n.defaultLocale = "en_SG.UTF-8";
  time.timeZone = "Asia/Shanghai";

  networking = {
    inherit hostName;
    wireless.iwd.enable = true;
  };

  systemd.network = {
    enable = true;
    wait-online = {
      enable = true;
      anyInterface = true;
    };
    networks = {
      "20-wired" = {
        name = "en*";
        address = [
          localNode.ipv4
          localNode.ipv6
        ];
      };
      "20-wireless" = {
        name = "wlan0";
        DHCP = "yes";
      };
    };
  };

  users.users.rebmit = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.passwd.path;
  };

  services.zram-generator.enable = lib.mkForce false;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64 * 1024;
  }];

  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
    opengl.enable = true;
  };

  programs = {
    dconf.enable = true;
    adb.enable = true;
    ssh = {
      startAgent = true;
      enableAskPassword = true;
      askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
    };
  };

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --cmd ${pkgs.writeShellScript "sway" ''
            while read -r l; do
              eval export $l
            done < <(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)

            exec systemd-cat --identifier=sway sway -D legacy-wl-drm
          ''}";
        };
      };
    };
    udev.extraHwdb = ''
      evdev:input:b*v046Dp4089*
        KEYBOARD_KEY_70039=esc
        KEYBOARD_KEY_70029=capslock
    '';
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };
  security.polkit.enable = true;

  system.stateVersion = "23.11";
}
