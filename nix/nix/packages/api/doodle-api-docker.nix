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
    Env = [
      "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" # TODO Might not be needed
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };

  meta = with lib; {
    description = "Quarkus backend-end for the doodle application (container)";
    homepage = "https://github.com/selabs-ur1/doodle";
    platforms = platforms.all;
  };
}
