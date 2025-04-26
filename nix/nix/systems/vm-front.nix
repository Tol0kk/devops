{
  config,
  lib,
  pkgs,
  ...
}: {
  users.groups.admin = {};
  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      password = "admin";
      group = "admin";
    };
  };

  modules.doodle.website.enable = true;

  # following configuration is added only when building VM with build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 4;
      graphics = false;
    };
  };

  system.stateVersion = "23.05";
}
