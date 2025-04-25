{
  pkgs,
  doodle-front-server,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "Doodle-Front";
  tag = "0.1.0";
  enableFakechroot = true;
  fakeRootCommands = ''
    ln -s  ${doodle-front-server}/bin/doodle-front-server /server
  '';
  config = {
    Cmd = ["/server"];
  };
}
