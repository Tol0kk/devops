{
  pkgs,
  doodle-api-server,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "Doodle-Api";
  tag = "0.1.0";
  enableFakechroot = true;
  fakeRootCommands = ''
    ln -s  ${doodle-api-server}/bin/doodle-api-server /server
  '';
  config = {
    Cmd = ["/server"];
  };
}
