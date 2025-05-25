{
  pkgs,
  self,
  config,
  lib,
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

    virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 4;
      graphics = false;
      diskSize = 32384;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
  };

  modules = {
    # Doodle
    doodle = {
      website.enable = true;
      backend.enable = true;
    };
  };

  networking.useDHCP = true;

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  systemd.services.loadDockerImages = let
    images = {
      etherpad = pkgs.dockerTools.pullImage {
        imageName = "etherpad/etherpad";
        imageDigest = "sha256:d92a977dd28fabcca8f36cc60c85a0223dee9acf545eb8e590a6972e5b3e13bd";
        sha256 = "sha256-k2OJMLlct6AyL8Mpl2v5ucfXx0EQiMSAnbkCMSa33xk=";
        finalImageName = "etherpad/etherpad";
        finalImageTag = "1.8.6";
      };
      mail = pkgs.dockerTools.pullImage {
        imageName = "bytemark/smtp";
        imageDigest = "sha256:9fd6ff05ac25141fe10ae4f9db0df361ad6139244ac280c398cc175bd2356a98";
        sha256 = "sha256-dLla7x65PqyAC0pYoGLd0S+pKbuP9tuSmImouypiwzw=";
        finalImageName = "bytemark/smtp";
        finalImageTag = "latest";
      };
      mysql = pkgs.dockerTools.pullImage {
        imageName = "mysql";
        imageDigest = "sha256:2247f6d47a59e5fa30a27ddc2e183a3e6b05bc045e3d12f8d429532647f61358";
        sha256 = "sha256-yyTB6eE0qcwB1fcTFLyPuC2HL75Ut4VZbBtmw0As7hQ=";
        finalImageName = "mysql";
        finalImageTag = "latest";
      };
    };
    loadCommands = pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (
        _: image: "${config.virtualisation.docker.package}/bin/docker load -i ${image}"
      )
      images);
  in {
    description = "Load multiple Docker images from Nix store";
    after = ["docker.service"];
    wants = ["docker.service"];
    wantedBy = ["docker-compose-doodle-services-root.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "load-docker-images" loadCommands}";
    };
  };

  # Containers
  virtualisation.oci-containers.containers."doodle-services-db" = {
    image = "mysql:latest";
    environment = {
      "MYSQL_DATABASE" = "tlc";
      "MYSQL_PASSWORD" = "tlc";
      "MYSQL_ROOT_PASSWORD" = "root";
      "MYSQL_USER" = "tlc";
    };
    ports = [
      "3306:3306/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=doodle-services_default"
    ];
  };
  systemd.services."docker-doodle-services-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-doodle-services_default.service"
    ];
    requires = [
      "docker-network-doodle-services_default.service"
    ];
    partOf = [
      "docker-compose-doodle-services-root.target"
    ];
    wantedBy = [
      "docker-compose-doodle-services-root.target"
    ];
  };
  virtualisation.oci-containers.containers."doodle-services-etherpad" = {
    image = "etherpad/etherpad:1.8.6";
    volumes = [
      "/home/titouan/Documents/ESIR/S8/DevOps/devops/nix/doodle/api/APIKEY.txt:/opt/etherpad-lite/APIKEY.txt:rw"
    ];
    ports = [
      "9001:9001/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=etherpad"
      "--network=doodle-services_default"
    ];
  };
  systemd.services."docker-doodle-services-etherpad" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-doodle-services_default.service"
    ];
    requires = [
      "docker-network-doodle-services_default.service"
    ];
    partOf = [
      "docker-compose-doodle-services-root.target"
    ];
    wantedBy = [
      "docker-compose-doodle-services-root.target"
    ];
  };
  virtualisation.oci-containers.containers."doodle-services-mail" = {
    image = "bytemark/smtp";
    ports = [
      "2525:25/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mail"
      "--network=doodle-services_default"
    ];
  };
  systemd.services."docker-doodle-services-mail" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-doodle-services_default.service"
    ];
    requires = [
      "docker-network-doodle-services_default.service"
    ];
    partOf = [
      "docker-compose-doodle-services-root.target"
    ];
    wantedBy = [
      "docker-compose-doodle-services-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-doodle-services_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f doodle-services_default";
    };
    script = ''
      docker network inspect doodle-services_default || docker network create doodle-services_default
    '';
    partOf = ["docker-compose-doodle-services-root.target"];
    wantedBy = ["docker-compose-doodle-services-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-doodle-services-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };

  # following configuration is added only when building VM with build-vm


  environment.systemPackages = [
    pkgs.dnsutils
  ];

  system.stateVersion = "23.05";
}
