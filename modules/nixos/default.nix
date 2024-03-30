{
  default = { ... }: {
    imports = [
      ./preset/baseline.nix
      ./custom/containers.nix
      ../common.nix
    ];
  };

  base = import ./base;

  secureboot = import ./preset/secureboot.nix;
}
