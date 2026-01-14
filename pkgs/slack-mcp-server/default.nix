{ lib
, stdenvNoCC
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

stdenvNoCC.mkDerivation (finalAttrs:
  let
    version = "1.1.28";

    # Platform-specific binary information
    assets = {
      "x86_64-linux" = {
        name = "slack-mcp-server-linux-amd64";
        hash = "sha256-Wc0lPDBvJB0xFPAM3i8dvIYLh70lUH4AokXHT5LL4lQ=";
      };
      "aarch64-linux" = {
        name = "slack-mcp-server-linux-arm64";
        hash = "sha256-7V6Rm8OBE9Bg8QuFRG3aajhbvCbpGzv93ml0sVK5iwY=";
      };
      "x86_64-darwin" = {
        name = "slack-mcp-server-darwin-amd64";
        hash = "sha256-wgEj3XlW5ND6wJqU1IKnov+4vUESh1hWfu/02lZVGxY=";
      };
      "aarch64-darwin" = {
        name = "slack-mcp-server-darwin-arm64";
        hash = "sha256-qwLne3nfh53FmYPEph6sEP/qb739jVUsXzl6nTesyTY=";
      };
    };

    sys = stdenvNoCC.hostPlatform.system;
    asset = assets.${sys} or (throw "slack-mcp-server: unsupported system ${sys}");
  in
  {
    pname = "slack-mcp-server";
    inherit version;

    src = fetchurl {
      url = "https://github.com/korotovsky/slack-mcp-server/releases/download/v${version}/${asset.name}";
      hash = asset.hash;
    };

    nativeBuildInputs = lib.optionals stdenvNoCC.isLinux [
      autoPatchelfHook
    ] ++ [ makeWrapper ];

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -Dm755 $src $out/bin/slack-mcp-server

      runHook postInstall
    '';

    meta = with lib; {
      description = "Model Context Protocol (MCP) server for Slack Workspaces";
      longDescription = ''
        The most powerful MCP Slack Server with no permission requirements, 
        Apps support, multiple transports (Stdio, SSE, HTTP), DMs, Group DMs, 
        and smart history fetch logic.
        
        Features:
        - Stealth and OAuth Modes
        - Enterprise Workspaces Support
        - Channel and Thread Support with #Name @Lookup
        - Smart History with pagination by date or message count
        - Search Messages with various filters
        - Safe Message Posting (disabled by default)
        - DM and Group DM support
        - Embedded user information
        - Cache support
        - Stdio/SSE/HTTP Transports & Proxy Support
      '';
      homepage = "https://github.com/korotovsky/slack-mcp-server";
      changelog = "https://github.com/korotovsky/slack-mcp-server/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = with maintainers; [ gotha ];
      mainProgram = "slack-mcp-server";
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    };
  })

