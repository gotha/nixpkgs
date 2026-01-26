{ lib, stdenvNoCC, fetchurl, appimageTools, undmg }:

let
  version = "3.0.2";
  pname = "redis-insight-bin";
  downloadBaseUrl = "https://github.com/redis/RedisInsight/releases/download";

  assets = {
    "x86_64-linux" = {
      url = "${downloadBaseUrl}/${version}/Redis-Insight-linux-x86_64.AppImage";
      hash = "sha256-Uv/KUgHvFPBR8pnbSnKmZyZTU4vvC7Z3zmq2kr0/lis=";
    };
    "x86_64-darwin" = {
      url = "${downloadBaseUrl}/${version}/Redis-Insight-mac-x64.dmg";
      hash = "sha256-GDQXIiUavdBsUslBgZMoh3PNkFzuzd4O08WFqkWVcdg=";
    };
    "aarch64-darwin" = {
      url = "${downloadBaseUrl}/${version}/Redis-Insight-mac-arm64.dmg";
      hash = "sha256-f9wQEkwqX5ylvZ+jjL1+u5m02y4tzNDTxYVahFd+T+k=";
    };
  };

  sys = stdenvNoCC.hostPlatform.system;
  asset = assets.${sys} or (throw "redis-insight-bin: unsupported system ${sys}");
in

if stdenvNoCC.isLinux then
  appimageTools.wrapType2 {
    inherit pname version;
    src = fetchurl {
      inherit (asset) url hash;
    };

    extraInstallCommands = ''
      # Create desktop file for application launchers
      mkdir -p $out/share/applications
      cat > $out/share/applications/redis-insight.desktop <<'EOF'
[Desktop Entry]
Name=RedisInsight
Comment=Redis GUI for streamlined Redis application development
Exec=${pname}
Icon=redis-insight
Terminal=false
Type=Application
Categories=Development;Database;
StartupWMClass=RedisInsight
StartupNotify=true
EOF

      # Substitute the actual binary name
      substituteInPlace $out/share/applications/redis-insight.desktop \
        --replace '${pname}' "$out/bin/${pname}"
    '';

    extraPkgs = pkgs: with pkgs; [ ];

    meta = with lib; {
      description = "Redis GUI for streamlined Redis application development";
      longDescription = ''
        RedisInsight is a visual tool that provides capabilities to design, develop,
        and optimize your Redis application. It works with any cloud provider as long
        as you run it on a host with network access to your Redis server. RedisInsight
        makes it easy to discover cloud databases and configure connection details with
        a single click. It allows you to automatically add Redis Enterprise Software
        and Redis Enterprise Cloud databases.
      '';
      homepage = "https://github.com/redis/RedisInsight";
      changelog = "https://github.com/redis/RedisInsight/releases/tag/${version}";
      license = licenses.sspl;
      maintainers = with maintainers; [ gotha ];
      mainProgram = "redis-insight-bin";
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    };
  }
else
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      inherit (asset) url hash;
    };

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r "Redis Insight.app" $out/Applications/

      # Create a wrapper script in bin
      mkdir -p $out/bin
      cat > $out/bin/redis-insight-bin <<EOF
      #!/bin/sh
      exec "$out/Applications/Redis Insight.app/Contents/MacOS/Redis Insight" "\$@"
      EOF
      chmod +x $out/bin/redis-insight-bin

      runHook postInstall
    '';

    meta = with lib; {
      description = "Redis GUI for streamlined Redis application development";
      longDescription = ''
        RedisInsight is a visual tool that provides capabilities to design, develop,
        and optimize your Redis application. It works with any cloud provider as long
        as you run it on a host with network access to your Redis server. RedisInsight
        makes it easy to discover cloud databases and configure connection details with
        a single click. It allows you to automatically add Redis Enterprise Software
        and Redis Enterprise Cloud databases.
      '';
      homepage = "https://github.com/redis/RedisInsight";
      changelog = "https://github.com/redis/RedisInsight/releases/tag/${version}";
      license = licenses.sspl;
      maintainers = with maintainers; [ gotha ];
      mainProgram = "redis-insight-bin";
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    };
  }

