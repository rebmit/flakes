{ config, lib, pkgs, inputs, self, mylib, ... }: {
  imports =
    [
      self.nixosModules.default
      inputs.mysecrets.nixosModules.secrets.kurumi
      inputs.home-manager.nixosModules.home-manager
    ]
    ++ (mylib.getItemPaths ./. [ "default.nix" "home.nix" ]);

  custom = {
    baseline.enable = true;
    system = {
      boot.secureboot.enable = false;
      disko.btrfs-luks-uefi-common = {
        enable = true;
        device = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
      };
    };
  };


  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    extraSpecialArgs = { inherit inputs mylib self; };
    users.rebmit = import ./home.nix;
  };

  boot.kernelParams = [
    "nouveau.config=NvGspRm=1"
    "nouveau.debug=info,VBIOS=info,gsp=debug"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    open = false;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  nix.settings.trusted-users = [ "root" "rebmit" ];
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-persistenced"
      ];
  };

  i18n.defaultLocale = "en_SG.UTF-8";
  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = "kurumi-a7s";
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
        DHCP = "yes";
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

  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
    opengl.enable = true;
  };

  programs = {
    dconf.enable = true;
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
          command = "${lib.getExe pkgs.greetd.tuigreet} --cmd ${pkgs.writeShellScript "hyprland" ''
            while read -r l; do
              eval export $l
            done < <(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)

            export NOUVEAU_USE_ZINK=1
            export WLR_NO_HARDWARE_CURSORS=1

            exec systemd-cat --identifier=hyprland Hyprland
          ''}";
        };
      };
    };
    udev.extraHwdb = ''
      evdev:atkbd:dmi:*
        KEYBOARD_KEY_3a=esc
        KEYBOARD_KEY_01=capslock
    '';
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
    };
    power-profiles-daemon.enable = true;
  };

  powerManagement.powertop.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };
  security.polkit.enable = true;

  system.stateVersion = "23.11";
}
