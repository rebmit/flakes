{ inputs
, lib
, system
, genSpecialArgs
, nixosModules
, homeModules ? [ ]
, specialArgs ? (genSpecialArgs system)
, myvars
, ...
}:
let
  inherit (inputs) nixpkgs home-manager nixos-generators self;
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules =
    nixosModules
    ++ [
      nixos-generators.nixosModules.all-formats
      self.nixosModules.default
      {
        custom.virtualisation.containersSpecialArgs = specialArgs;
      }
    ]
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
