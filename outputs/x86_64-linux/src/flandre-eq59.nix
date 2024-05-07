{ inputs
, lib
, system
, genSpecialArgs
, myvars
, mylib
, ...
}:
let
  name = "flandre-eq59";
  tags = [ "flandre" "homelab" "overlay" ];
  baseModules = {
    nixosModules = map mylib.relativeToRoot [
      "hosts/${name}"
    ];
  };
  systemArgs = baseModules // { inherit inputs lib system genSpecialArgs myvars; };
in
{
  nixosConfigurations."${name}" = mylib.nixosSystem systemArgs;

  colmena."${name}" = mylib.colmenaSystem (systemArgs // { inherit tags; });

  packages."${name}" = inputs.self.nixosConfigurations."${name}".config.formats.iso;
}
