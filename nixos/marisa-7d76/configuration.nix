{
  config,
  lib,
  pkgs,
  inputs,
  self,
  mylib,
  ...
}: {
  imports = [
    self.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  preset = {
    baseline.enable = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yml;
    secrets = {
      passwd.neededForUsers = true;
    };
    age = {
      keyFile = "/var/lib/sops.key";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    extraSpecialArgs = {inherit inputs mylib;};
    users.rebmit = import (self.outPath + "/home-manager/rebmit@marisa-7d76");
  };

  nix.settings.trusted-users = ["root" "rebmit"];
  nixpkgs.overlays = [self.overlays.default];

  i18n.defaultLocale = "en_SG.UTF-8";
  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = "marisa-7d76";
    useNetworkd = true;
    useDHCP = true;
    wireless.iwd.enable = true;
  };

  boot = {
    tmp.useTmpfs = true;
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
    };
  };

  users.users.rebmit = {
    isNormalUser = true;
    extraGroups = ["wheel"];
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

            exec systemd-cat --identifier=hyprland Hyprland
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

  security.polkit.enable = true;

  system.stateVersion = "23.11";
}
