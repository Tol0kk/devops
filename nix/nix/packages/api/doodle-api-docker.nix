{
  pkgs,
  doodle-api-server,
  lib,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "doodle-api";
  tag = "0.1.0";
  enableFakechroot = true;
  fakeRootCommands = ''
    ln -s  ${doodle-api-server}/bin/doodle-api-server /server
  '';
  config = {
    Cmd = ["/server"];
    Env = [
      "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
