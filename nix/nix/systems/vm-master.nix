{
  config,
  pkgs,
  self,
  ...
}: let
  kubeMasterIP = "192.168.168.102";
  kubeMasterHostname = "192.168.168.102";
  kubeMasterAPIServerPort = 6443;
in {
  imports = [
    self.nixosModules.ovhcloud
    "${self}/nix/modules/hardware-configurations/vm-master-x86_64-linux-hardware-configuration.nix"
  ];

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 4;
      graphics = false;
    };
  };

  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      password = "admin";

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

  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${toString kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  system.stateVersion = "23.05";
}
