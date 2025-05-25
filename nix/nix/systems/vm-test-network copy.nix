{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    docker-compose
    dnsmasq
  ];

  # Configure dnsmasq for Docker DNS resolution
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      # Listen on loopback interface
      listen-address=127.0.0.1
      # Bind to interface to prevent conflicts
      bind-interfaces
      # Resolve *.docker.local to Docker bridge network
      address=/docker.local/172.17.0.1
      # For custom networks, you'll need to get the gateway IP
      # address=/docker.local/$(docker network inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' my-network)
    '';
  };

  # Configure DNS resolution
  networking = {
    # Use dnsmasq as DNS resolver
    nameservers = [ "127.0.0.1" "1.1.1.1" "8.8.8.8" ];
    # Search domain for Docker containers
    search = [ "docker.local" ];
  };

  # Add firewall rules if needed
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ]; # For web services
    trustedInterfaces = [ "docker0" ]; # Allow access to Docker bridge
  };

  # Optional: Create a custom Docker network at boot
  systemd.services.create-docker-network = {
    description = "Create custom Docker network";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker network create --driver bridge my-network || true";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Optional: Add host entries for important containers
  networking.extraHosts = ''
    127.0.0.1 localhost docker.local
    172.17.0.1 docker-gateway.docker.local
  '';

  # Optional: Example container definition
  virtualisation.oci-containers.containers = {
    webapp = {
      image = "nginx:latest";
      extraOptions = [
        "--network=my-network"
        "--hostname=webapp"
      ];
      ports = [ "80:80" ];
    };
  };
}