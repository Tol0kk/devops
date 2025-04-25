{
  pkgsStatic,
  pkgs,
  doodle-api,
}: let
  jre = pkgs.jre_minimal.override {
    modules = [
      # mandatory java modules
      "java.base"
      "java.logging"
      "java.sql"
      "java.sql.rowset"
      "jdk.hotspot.agent"
      "jdk.editpad"
      "jdk.internal.vm.compiler.management"
      "jdk.security.jgss"

      # Maybe needed. idk
      # "java.compiler"
      # "java.datatransfer"
      # "java.desktop"
      # "java.instrument"
      # "java.management"
      # "java.management.rmi"
      # "java.naming"
      # "java.net.http"
      # "java.prefs"
      # "java.rmi"
      # "java.scripting"
      # "java.se"
      # "java.security.sasl"
      # "java.smartcardio"
      # "java.transaction.xa"
      # "java.xml.crypto"
      # "java.xml"
      # "jdk.accessibility"
      # "jdk.aot"
      # "jdk.attach"
      # "jdk.charsets"
      # "jdk.compiler"
      # "jdk.crypto.cryptoki"
      # "jdk.crypto.ec"
      # "jdk.dynalink"
      # "jdk.httpserver"
      # "jdk.internal.ed"
      # "jdk.internal.jvmstat"
      # "jdk.internal.le"
      # "jdk.internal.opt"
      # "jdk.internal.vm.ci"
      # "jdk.internal.vm.compiler"
      # "jdk.jartool"
      # "jdk.javadoc"
      # "jdk.jcmd"
      # "jdk.jconsole"
      # "jdk.jdeps"
      # "jdk.jdi"
      # "jdk.jdwp.agent"
      # "jdk.jfr"
      # "jdk.jlink"
      # "jdk.jshell"
      # "jdk.jsobject"
      # "jdk.jstatd"
      # "jdk.localedata"
      # "jdk.management.agent"
      # "jdk.management.jfr"
      # "jdk.management"
      # "jdk.naming.dns"
      # "jdk.naming.ldap"
      # "jdk.naming.rmi"
      # "jdk.net"
      # "jdk.pack"
      # "jdk.rmic"
      # "jdk.scripting.nashorn"
      # "jdk.scripting.nashorn.shell"
      # "jdk.sctp"
      # "jdk.security.auth"
      # "jdk.security.jgss"
      # "jdk.unsupported.desktop"
      # "jdk.unsupported"
      # "jdk.xml.dom"
      # "jdk.zipfs"
    ];
    jdk = pkgs.jdk11_headless;
  };
  busybox = pkgsStatic.busybox.override {
    useMusl = true;
    enableStatic = true;
  };
in
  pkgsStatic.writeScriptBin "doodle-api-server" ''
    #!${busybox}/bin/sh
    ${jre}/bin/java -jar ${doodle-api}/tlcdemoApp-1.0.0-SNAPSHOT-runner.jar
  ''
