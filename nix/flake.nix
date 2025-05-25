{
  description = "A Nix-flake-based Java development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
          };
        });
    libs = import nix/libs {inherit (nixpkgs) lib;};
  in {
    packages = forEachSupportedSystem ({pkgs}: let
      doodle-api = pkgs.callPackage ./nix/packages/api/default.nix {};
      doodle-api-server = pkgs.callPackage ./nix/packages/api/doodle-api-server.nix {inherit doodle-api;};
      doodle-api-docker = pkgs.callPackage ./nix/packages/api/doodle-api-docker.nix {inherit doodle-api-server;};
      doodle-front = pkgs.callPackage ./nix/packages/front/default.nix {};
      doodle-front-server = pkgs.callPackage ./nix/packages/front/doodle-front-server.nix {inherit doodle-front;};
      doodle-front-docker = pkgs.callPackage ./nix/packages/front/doodle-front-docker.nix {inherit doodle-front-server;};
    in {
      # Backend
      inherit doodle-api doodle-api-docker doodle-api-server;
      # Front
      inherit doodle-front doodle-front-docker doodle-front-server;
    });

    apps = forEachSupportedSystem ({pkgs}:
      {
        # Back
        doodle-api-server = {
          type = "app";
          program = "${self.packages.${pkgs.system}.doodle-api-server}/bin/doodle-api-server";
        };
        # Front
        doodle-front-server = {
          type = "app";
          program = "${self.packages.${pkgs.system}.doodle-front-server}/bin/doodle-front-server";
        };
      }
      // libs.mkVMsApp {inherit self;});

    nixosConfigurations = import nix/systems {inherit inputs nixpkgs libs self;};

    nixosModules.ovhcloud.imports = [
      nix/modules/single-disk.nix
    ];

    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Frontend
          nodejs_23
          nodePackages."@angular/cli"
          nest-cli
          nodePackages.typescript
          nodePackages.typescript-language-server

          # Backend
          jdk11
          maven
          

          # Docker
          dive
          compose2nix

          # Kubectl
          minikube

          # Terraform
          tenv
          # Open Stack
          openstackclient
        ];
      };
    });
  };
}
