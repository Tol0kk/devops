{
  doodle-front,
  pkgsStatic,
  port ? 3000,
  apiProxyTo ? "mysql:8080/api"
}: let
  busybox = pkgsStatic.busybox.override {
    useMusl = true;
    enableStatic = true;
  };
  httpdConf = pkgsStatic.writeText "httpd.conf" ''
    P:/api:${apiProxyTo}
  '';
in
  pkgsStatic.writeScriptBin "doodle-front-server" ''
    #!${busybox}/bin/sh
    ${busybox}/bin/httpd -f -p ${builtins.toString port} -h ${doodle-front} -c ${httpdConf}
  ''
