{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.preset.baseline;
in
  with lib; {
    options.preset.baseline = {
      enable = mkEnableOption "baseline configuration";
    };

    config = mkIf cfg.enable {
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
          "ia32_emulation=0"
        ];
        kernel = {
          sysctl = {
            "kernel.panic" = 10;
            "kernel.sysrq" = 1;
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
            "net.core.rmem_max" = 2500000;
            "net.core.wmem_max" = 2500000;
          };
        };
      };

      nix = {
        channel.enable = false;
        gc = {
          automatic = true;
          options = "--delete-older-than 14d";
          dates = "weekly";
        };
        settings = {
          auto-optimise-store = true;
          flake-registry = "/etc/nix/registry.json";
          experimental-features = ["nix-command" "flakes" "auto-allocate-uids" "cgroups"];
          auto-allocate-uids = true;
          use-cgroups = true;
        };
      };

      nixpkgs.config = {
        allowNonSource = false;
        allowNonSourcePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "sof-firmware"
            "temurin-bin"
            "cargo-bootstrap"
            "rustc-bootstrap"
            "rustc-bootstrap-wrapper"
          ];
      };

      networking.firewall.enable = lib.mkDefault false;

      services = {
        dbus.implementation = "broker";
        fstrim.enable = true;
        journald = {
          extraConfig = ''
            SystemMaxUse=1G
          '';
        };
        resolved = {
          dnssec = "false";
          llmnr = "false";
          extraConfig = ''
            MulticastDNS=off
          '';
        };
        zram-generator = {
          enable = true;
          settings.zram0 = {
            compression-algorithm = "zstd";
            zram-size = "ram";
          };
        };
      };

      users.mutableUsers = false;

      programs.command-not-found.enable = false;

      environment.stub-ld.enable = false;

      documentation.nixos.enable = mkForce false;
    };
  }
