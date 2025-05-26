{
  pkgs,
  doodle-front-server,
  lib,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "docker.io/library/doodle-front";
  tag = "latest";
  created = "now";
  enableFakechroot = true;
  fakeRootCommands = ''
    ln -s  ${doodle-front-server}/bin/doodle-front-server /server
  '';
  config = {
    Cmd = ["/server"];
  };
}
