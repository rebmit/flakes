{
  default = { ... }: {
    imports = [
      ./preset/baseline.nix
    ];
  };

  secureboot = import ./preset/secureboot.nix;
}
