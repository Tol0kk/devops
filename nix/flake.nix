{
  description = "A Nix-flake-based Java development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
          };
        });
  in {
    packages = forEachSupportedSystem ({pkgs}: let
      doodle-front = pkgs.callPackage ./nix/packages/front/default.nix {};
      doodle-front-server = pkgs.callPackage ./nix/packages/front/doodle-front-server.nix {inherit doodle-front;};
      doodle-front-docker = pkgs.callPackage ./nix/packages/front/doodle-front-docker.nix {inherit doodle-front-server;};
    in {
      # Front
      inherit doodle-front doodle-front-docker doodle-front-server;
    });

    apps = forEachSupportedSystem ({pkgs}: {
      # Front
      doodle-front-server = {
        type = "app";
        program = "${self.packages.${pkgs.system}.doodle-front-server}/bin/doodle-front-server";
      };
    });

    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_23
          nodePackages."@angular/cli"
          nest-cli
          nodePackages.typescript
          nodePackages.typescript-language-server
          sqlite
          python3Minimal

          # Docker
          dive
        ];
      };
    });
  };
}
