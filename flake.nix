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
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.38.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mysecrets = {
      url = "git+ssh://git@github.com/rebmit/secrets.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      mylib = import ./lib { inherit lib; };
      mypkgs = import ./pkgs { inherit mylib; };
      myvars = import ./vars { inherit lib mylib; };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          packages = mypkgs.packages pkgs;
          legacyPackages = pkgs;
          devShells.default = with pkgs;
            mkShell {
              nativeBuildInputs = [
                colmena
                nvfetcher
                just
              ];
            };
          inherit mylib;
        }
      )
    // {
      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;
      overlays.default = mypkgs.overlay;
      nixosConfigurations =
        {
          "marisa-7d76" = lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./nixos/marisa-7d76 ];
            specialArgs = {
              inherit inputs mylib self myvars;
            };
          };
          "kurumi-a7s" = lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./nixos/kurumi-a7s ];
            specialArgs = {
              inherit inputs mylib self myvars;
            };
          };
        }
        // self.colmenaHive.nodes;
      colmenaHive = inputs.colmena.lib.makeHive {
        meta = {
          specialArgs = {
            inherit self inputs mylib myvars;
            data.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4h3+0cpr7XGAAEzoXrvA+Oap+eyeugCHMX/BVIbPYS rebmit@marisa-7d76"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs/vNhm4QV8tuks1k/W4dlpvjERwGJwX1d/YqhZ7zGc rebmit@kurumi-a7s"
            ];
          };
          nixpkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
          };
        };
        "flandre-eq59" = { ... }: {
          deployment.targetHost = "flandre-eq59.link.rebmit.internal";
          imports = [ ./nixos/flandre-eq59 ];
        };
        "misaka-lax02" = { ... }: {
          deployment.targetHost = "misaka-lax02";
          imports = [ ./nixos/misaka-lax02 ];
        };
      };
    };
}
