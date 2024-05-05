{ self
, nixpkgs
, git-hooks
, flake-utils
, mysecrets
, ...
} @ inputs:
let
  inherit (nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib mylib mysecrets; };
  mypkgs = import ../pkgs { inherit lib mylib; };

  genSpecialArgs = system:
    inputs
    // {
      inherit mylib myvars mypkgs system;
    };
  args = { inherit inputs lib mylib myvars mypkgs genSpecialArgs; };

  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
  };

  allSystems = nixosSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
in
flake-utils.lib.eachSystem allSystemNames
  (
    system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ mypkgs.overlay ];
      };
    in
    {
      formatter = pkgs.nixpkgs-fmt;
      packages = allSystems.${system}.packages // (mypkgs.packages pkgs);
      legacyPackages = pkgs;
      checks = {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = mylib.relativeToRoot ".";
          hooks = {
            nixpkgs-fmt.enable = true;
            typos = {
              enable = true;
              settings = {
                write = false;
                configPath = "./.typos.toml";
              };
            };
            prettier = {
              enable = true;
              settings = {
                write = true;
              };
            };
          };
        };
      };
      devShells = {
        default = with pkgs; mkShell {
          nativeBuildInputs = [
            deadnix
            statix
            typos
            nodePackages.prettier
            colmena
            nvfetcher
          ];
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
          '';
        };
      };
    }
  )
  // {
  debugAttrs = { inherit mylib myvars mypkgs nixosSystems allSystems allSystemNames; };

  homeManagerModules = import ../modules/home-manager;
  nixosModules = import ../modules/nixos;

  nixosConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or { }) nixosSystemValues);

  colmena = {
    meta = (
      let
        system = "x86_64-linux";
      in
      {
        nixpkgs = import nixpkgs { inherit system; };
        specialArgs = genSpecialArgs system;
      }
    ) // {
      nodeSpecialArgs =
        lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or { }) nixosSystemValues);
    };
  } // lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) nixosSystemValues);
}
