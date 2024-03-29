{
  default = { ... }: {
    imports = [
      ./preset/baseline.nix
      ../common.nix
    ];
  };

  base = import ./base;

  secureboot = import ./preset/secureboot.nix;
}
