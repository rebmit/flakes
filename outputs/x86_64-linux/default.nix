{ inputs
, lib
, ...
} @ args:
let
  inherit (inputs) haumea;
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  dataValues = builtins.attrValues data;
  outputs = {
    nixosConfigurations =
      lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or { }) dataValues);
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataValues);
    colmenaMeta = {
      nodeSpecialArgs =
        lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or { }) dataValues);
    };
    colmena = lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) dataValues);
  };
in
outputs // {
  inherit data;
}
