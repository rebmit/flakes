{ inputs
, lib
, system
, genSpecialArgs
, nixosModules
, homeModules ? [ ]
, specialArgs ? (genSpecialArgs system)
, myvars
, tags ? [ ]
, ...
}:
let
  inherit (inputs) home-manager;
in
{ name, ... }: {
  deployment = {
    inherit tags;
    targetHost = name;
  };

  imports =
    nixosModules
    ++ (
      lib.optionals ((lib.lists.length homeModules) > 0)
        [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${myvars.username}".imports = homeModules;
          }
        ]
    );
}
