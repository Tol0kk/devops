{
  lib,
  # jre,
  # makeWrapper,
  maven,
  jdk11_headless,
}:
maven.buildMavenPackage rec {
  pname = "Doodle-Api";
  version = "1.2.1";

  mvnJdk = jdk11_headless;
  src = lib.cleanSource ../../../doodle/api;

  mvnHash = "sha256-XhuWF7F89LRXl7CL/mnQsc6IGElhh5O59c54VK1EPXI=";

  mvnParameters = lib.escapeShellArgs [
    "-DskipTests"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r target/* $out/.

    runHook postInstall
  '';

  meta = with lib; {
    description = "Quarkus backend-end for the doodle application (resources)";
    homepage = "https://github.com/selabs-ur1/doodle";
    platforms = platforms.all;
  };
}
