# default.nix
{
  inputs,
  nixpkgs,
  libs,
  self,
  ...
}: let
  inherit (nixpkgs) lib;
  inherit (builtins) attrNames readDir listToAttrs map;
  inherit (lib) hasSuffix removeSuffix genAttrs;

  supportedSystems = ["x86_64-linux" "aarch64-linux"];
  systemsFolder = ./.;

  # Get all .nix files from the systemsFolder
  files = lib.filter (
    f:
      f != "default.nix" && hasSuffix ".nix" f
  ) (attrNames (readDir systemsFolder));

  mkSys = name: file: (system: {
    name = "${name}-${system}";
    value = libs.mkSystem {
      inherit system inputs self;
      config = systemsFolder + "/${file}";
    };
  });

  mkSysList = file: let
    name = removeSuffix ".nix" file;
  in (map (mkSys name file) supportedSystems);

  listSystems =
    map mkSysList
    files;

  systems = listToAttrs (lib.lists.flatten listSystems);
in
  systems
