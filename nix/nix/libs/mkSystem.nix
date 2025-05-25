{lib, ...}:
# Function mkSystem {system, config}
{
  system,
  config,
  inputs,
  self,
  ...
}: let
  inherit (inputs) self nixpkgs;
  pacakgesOverlay = final: prev: self.packages.${system};

  overlays = [pacakgesOverlay];
in
  lib.nixosSystem
  {
    inherit system;
    pkgs = import nixpkgs {
      inherit system overlays;
    };
    specialArgs = {
      inherit inputs self;
    };
    modules = [
      inputs.disko.nixosModules.disko
      ../modules/doodle/website.nix
      ../modules/doodle/backend.nix
      config
    ];
  }
