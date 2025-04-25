{
  pkgs,
  doodle-api-server,
  lib,
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

  meta = with lib; {
    description = "Quarkus backend-end for the doodle application (container)";
    homepage = "https://github.com/selabs-ur1/doodle";
    platforms = platforms.all;
  };
}
