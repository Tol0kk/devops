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
    libs = import ../nix/nix/libs {inherit (nixpkgs) lib;};
  in {
    nixosConfigurations = import ../nix/nix/systems {inherit inputs nixpkgs libs self;};

    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
           pkgs.bashInteractive

          # Kubectl
          minikube

          # Terraform
          tenv
          # Open Stack
          openstackclient
        ];
         shellHook = ''
            echo "🌀 Welcome to the Terraform envvironment!""
          '';
      };
    });
  };
}
