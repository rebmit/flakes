{ inputs
, lib
, system
, genSpecialArgs
, myvars
, mylib
, ...
}:
let
  name = "konpaku-fra0";
  tags = [ "konpaku" "infra" "overlay" ];
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
