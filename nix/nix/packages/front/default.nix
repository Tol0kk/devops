{
  buildNpmPackage,
  lib,
}:
buildNpmPackage {
  pname = "Doodle-Front";
  version = "1.0.0";

  src = lib.cleanSource ../../../doodle/front;

  npmPackFlags = ["--ignore-scripts" "--legacy-peer-deps"];

  NODE_OPTIONS = "--openssl-legacy-provider";
  dontNpmBuild = false;

  npmDepsHash = "sha256-R1Rp+xBrUFHbeFUnZoSYkfZLvzkZvWJt5WuvD2hYQbM=";

  # # Prevent npm from writing outside the store
  # dontNpmInstall = true;

  buildPhase = ''
    export HOME=$TMPDIR
    npx ng build --prod
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist/tlcfront/* $out/.
  '';

  meta = with lib; {
    description = "Angular front-end for the doodle application (resources)";
    homepage = "https://github.com/selabs-ur1/doodle";
    platforms = platforms.all;
  };
}
