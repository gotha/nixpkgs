{ lib, buildNpmPackage, fetchurl, nodejs }:

buildNpmPackage rec {
  pname = "context7-mcp";
  version = "2.2.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@upstash/context7-mcp/-/context7-mcp-${version}.tgz";
    hash = "sha256-lbeRTlD8tMt9c9fsJ5IFtaGEmF/9tHzzr1BT6Y5gq9k=";
  };

  sourceRoot = "package";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-HkPREswr8jzwxH8mIs3iBS4dmDHwnM4MEtOSPFWX8zk=";

  dontNpmBuild = true;

  # Skip tests
  doCheck = false;

  # Custom install phase to handle scoped package name
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/@upstash/context7-mcp
    cp -r dist package.json $out/lib/node_modules/@upstash/context7-mcp/
    cp -r node_modules $out/lib/node_modules/@upstash/context7-mcp/

    mkdir -p $out/bin
    ln -s $out/lib/node_modules/@upstash/context7-mcp/dist/index.js $out/bin/context7-mcp
    chmod +x $out/lib/node_modules/@upstash/context7-mcp/dist/index.js

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "Context7 MCP Server - Up-to-date code documentation for LLMs and AI code editors";
    longDescription = ''
      Context7 MCP is a Model Context Protocol server that provides up-to-date,
      version-specific documentation and code examples for libraries and frameworks.
      It fetches documentation directly from the source and places it into your
      LLM's context, eliminating outdated examples and hallucinated APIs

      Features:
      - Up-to-date documentation for popular libraries
      - Version-specific code examples
      - Integration with AI code editors like Cursor, VS Code, Claude Code
      - Support for both local and remote server modes
      - Optional API key for higher rate limits and private repositories
    '';
    homepage = "https://github.com/upstash/context7";
    changelog = "https://github.com/upstash/context7/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "context7-mcp";
  };
}
