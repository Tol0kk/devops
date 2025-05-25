{
  pkgs,
  self,
  config,
  lib,
  ...
}: {
  imports = [
    self.nixosModules.ovhcloud
  ];

  users.groups.admin = {};
  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      password = "admin";
      group = "admin";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVqwT7RY9lxYNoAo1y9wHOa9wcmx6tYXmf1EJ7/hDEv Olenixen"
      ];
    };
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false; # Change to false if only using SSH keys
  };

  environment.systemPackages = [
    pkgs.dnsutils
  ];

  system.stateVersion = "23.05";
}
