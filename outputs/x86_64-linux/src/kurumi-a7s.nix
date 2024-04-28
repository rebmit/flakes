{ inputs
, lib
, system
, genSpecialArgs
, myvars
, mylib
, ...
}:
let
  name = "kurumi-a7s";
  baseModules = {
    nixosModules = map mylib.relativeToRoot [
      "hosts/${name}"
    ];
    homeModules = map mylib.relativeToRoot [
      "hosts/${name}/home.nix"
    ];
  };
  systemArgs = baseModules // { inherit inputs lib system genSpecialArgs myvars; };
in
{
  nixosConfigurations."${name}" = mylib.nixosSystem systemArgs;

  packages."${name}" = inputs.self.nixosConfigurations."${name}".config.formats.iso;
}
