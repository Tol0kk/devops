{
  pkgs,
  doodle-front-server,
  lib,
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

  meta = with lib; {
    description = "Angular front-end for the doodle application (container)";
    homepage = "https://github.com/selabs-ur1/doodle";
    platforms = platforms.all;
  };
}
