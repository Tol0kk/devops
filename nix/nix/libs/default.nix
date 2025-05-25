{lib, ...}: {
  mkSystem = import ./mkSystem.nix {inherit lib;};
  mkVMsApp = import ./mkVMsApp.nix {inherit lib;};
}
