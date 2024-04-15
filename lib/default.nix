{ lib }: rec {
  networking = import ./networking.nix { inherit lib; };

  getItemNames = path: keep:
    let
      inherit (lib) types;
      pred =
        if keep == null
        then (_: _: true)
        else if types.singleLineStr.check keep
        then (name: type: !(name == keep))
        else if lib.isFunction keep
        then keep
        else if (types.listOf types.singleLineStr).check keep
        then (name: type: !(builtins.elem name keep))
        else throw "importDir predicate should be a string, function, or list of strings";
      isNix = name: type:
        (type == "regular" && lib.hasSuffix ".nix" name)
        || (lib.pathIsRegularFile "${path}/${name}/default.nix");
      pred' = name: type: (isNix name type) && (pred name type);
    in
    with builtins; (
      attrNames
        (lib.filterAttrs pred' (readDir path))
    );

  getItemPaths = path: keep: (
    map
      (name: path + "/${name}")
      (getItemNames path keep)
  );

  mapItemNames = path: keep: f:
    with builtins;
    listToAttrs (
      map
        (name: {
          inherit name;
          value = f name;
        })
        (
          map
            (name: lib.removeSuffix ".nix" name)
            (getItemNames path keep)
        )
    );
}
