{
  default = { mylib, lib, pkgs, self, ... }: {
    imports = mylib.getItemPaths ./. [ "default.nix" ];

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
        experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
        auto-allocate-uids = true;
        use-cgroups = true;
      };
    };

    nixpkgs = {
      overlays = [ self.overlays.default ];
      config = {
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
    };

    environment = {
      systemPackages = with pkgs; [
        neovim
      ];
      variables = {
        EDITOR = "nvim";
      };
    };

    services.dbus.implementation = "broker";

    users.mutableUsers = false;

    environment.stub-ld.enable = false;

    programs.command-not-found.enable = false;
    documentation.nixos.enable = lib.mkForce false;

    system.stateVersion = "23.11";
  };
}
