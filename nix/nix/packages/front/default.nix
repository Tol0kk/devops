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
    description = "A packaged Angular static site";
    homepage = "https://example.com";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
