{
  doodle-front,
  pkgsStatic,
  port ? 3000
}: let
  busybox = pkgsStatic.busybox.override {
    useMusl = true;
    enableStatic = true;
  };
in
  pkgsStatic.writeScriptBin "doodle-front-server" ''
    #!${busybox}/bin/sh
    ${busybox}/bin/httpd -f -p ${builtins.toString port} -h ${doodle-front}
  ''
