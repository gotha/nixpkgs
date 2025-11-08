{ lib, stdenvNoCC, fetchzip, makeWrapper, zulu17 }:

stdenvNoCC.mkDerivation (finalAttrs:
  let
    version = "1.61.0";
    downloadBaseUrl = "https://github.com/smithy-lang/smithy/releases/download";
    assets = {
      "x86_64-linux" = {
        url = "${downloadBaseUrl}/${version}/smithy-cli-linux-x86_64.zip";
        hash = "sha256-535m0qmju+PvLlZm+XclcgG9eIj1uEmZupxMAjOnpAg=";
      };
      "aarch64-linux" = {
        url = "${downloadBaseUrl}/${version}/smithy-cli-linux-aarch64.zip";
        hash = "sha256-MbrwaUN9PPpVe8QZw5oN1Gp1BIEQSYYhsgrWgMNkGwE=";
      };
      "x86_64-darwin" = {
        url = "${downloadBaseUrl}/${version}/smithy-cli-darwin-x86_64.zip";
        hash = "sha256-va21jZm7/R54VCyxJxMhh+ppUhYRZ1PEl8PMVtnlS58=";
      };
      "aarch64-darwin" = {
        url = "${downloadBaseUrl}/${version}/smithy-cli-darwin-aarch64.zip";
        hash = "sha256-R9SGzJvCZx0SnQqua+u+LbMIOwMxn6u2ylWc//xC9Sc=";
      };
    };

    sys = stdenvNoCC.hostPlatform.system;
    asset = assets.${sys} or (throw "smithy-cli: unsupported system ${sys}");
  in {
    pname = "smithy-cli";
    inherit version;

    src = fetchzip {
      inherit (asset) url hash;
      stripRoot = true;
    };

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall

      install -Dm555 bin/smithy -t $out/libexec/smithy/bin
      mkdir -p $out/libexec/smithy/lib
      cp -r ./lib/* $out/libexec/smithy/lib

      # make sure we use nix's java
      substituteInPlace $out/libexec/smithy/bin/smithy \
        --replace 'JAVACMD="$JAVA_HOME/bin/java"' 'JAVACMD="java"'

      rm -f $out/libexec/smithy/bin/java 2>/dev/null || true

      # expose entrypoint and provide Java on PATH
      makeWrapper $out/libexec/smithy/bin/smithy $out/bin/smithy \
        --set SMITHY_HOME $out/libexec/smithy \
        --prefix PATH : ${lib.makeBinPath [ zulu17 ]}

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/smithy --version >/dev/null
    '';

    meta = with lib; {
      description = "Command-line interface for the Smithy IDL and tooling";
      homepage = "https://github.com/smithy-lang/smithy";
      license = licenses.asl20;
      maintainers = with maintainers; [ gotha ];
      platforms =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      mainProgram = "smithy";
    };
  })
