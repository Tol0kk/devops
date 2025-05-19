{
  pkgs,
  doodle-front-server,
  lib,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "doodle-front";
  tag = "0.1.0";
  enableFakechroot = true;
  fakeRootCommands = ''
    ln -s  ${doodle-front-server}/bin/doodle-front-server /server
  '';
  config = {
    Cmd = ["/server"];
  };
}
