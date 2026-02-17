{ lib, stdenvNoCC, fetchzip, nodejs, makeWrapper }:

stdenvNoCC.mkDerivation rec {
  pname = "auggie";
  version = "0.16.1";

  src = fetchzip {
    url =
      "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-${version}.tgz";
    hash = "sha256-n3I2RkhGACicf5Cd4F6udoKUX+CXifM0iaA0eWy9lko=";
    stripRoot = true;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/auggie
    cp -r . $out/lib/auggie/

    makeWrapper ${nodejs}/bin/node $out/bin/auggie \
      --add-flags "$out/lib/auggie/augment.mjs"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Auggie CLI Client by Augment Code";
    longDescription = ''
      Auggie is a command-line interface (CLI) client for Augment Code.
      It provides terminal-based access to Augment's AI coding assistant
      capabilities, enabling developers to interact with Augment's features
      directly from the command line.
    '';
    homepage = "https://augmentcode.com";
    # Custom license - publicly distributed on npm, free to use
    license = {
      fullName = "Augment Code License";
      shortName = "augment-code";
      url = "https://www.augmentcode.com/terms-of-service";
    };
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "auggie";
  };
}

