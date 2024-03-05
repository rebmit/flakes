{
  description = ''
    a nix flake for reproducing the system configurations
    used on rebmit's devices.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    mylib = import ./lib {inherit lib;};
    mypkgs = import ./pkgs {inherit mylib;};
  in
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"]
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in {
        formatter = pkgs.alejandra;
        packages = mypkgs.packages pkgs;
        legacyPackages = pkgs;
        devShells.default = with pkgs;
          mkShell {
            nativeBuildInputs = [
            ];
          };
      }
    )
    // {
      nixosModules = import ./modules;
      overlays.default = mypkgs.overlay;
      nixosConfigurations = {
        "marisa-7d76" = import ./nixos/marisa-7d76 {
          system = "x86_64-linux";
          inherit self nixpkgs inputs mylib;
        };
      };
    };
}
