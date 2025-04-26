{
  lib,
  ...
}: let
in
  # Function mkSystem {system, config}
  {
    system,
    config,
    inputs,
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
      modules = [
        ../modules/doodle/website.nix
        config
      ];
    }
