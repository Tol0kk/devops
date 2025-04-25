{
  doodle-front,
  pkgsStatic,
}: let
  busybox = pkgsStatic.busybox.override {
    # enableMinimal = true;
    useMusl = true;
    enableStatic = true;
  };
in
  pkgsStatic.writeScriptBin "doodle-front-server" ''
    #!${busybox}/bin/sh
    ${busybox}/bin/httpd -f -p 3000 -h ${doodle-front}
  ''
