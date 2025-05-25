{
  lib,
  ...
}:

{
  self,
  ...
}: 
let 
  inherit (builtins) attrNames listToAttrs map;

  vmsNames = attrNames self.nixosConfigurations;

  mkVMApp = name: 
      {
        type = "app";
        program = "${self.nixosConfigurations.${name}.config.system.build.vm}/bin/run-nixos-vm";
      };

  vmsApp = map (name: {
    inherit name;
    value = mkVMApp name;
  }) vmsNames;
in
  (listToAttrs vmsApp)