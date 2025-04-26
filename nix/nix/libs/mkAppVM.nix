name: self: {
  type = "app";
  program = "${self.nixosConfigurations.${name}.config.system.build.vm}/bin/run-nixos-vm";
}
