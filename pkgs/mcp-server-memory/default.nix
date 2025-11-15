{ lib, buildNpmPackage, fetchurl, nodejs }:

buildNpmPackage rec {
  pname = "mcp-server-memory";
  version = "2025.9.25";

  src = fetchurl {
    url = "https://registry.npmjs.org/@modelcontextprotocol/server-memory/-/server-memory-${version}.tgz";
    hash = "sha256-tKCcrZceZT65N1Mh7Th0J2T1RphsBDqwVl/6m4jSq0M=";
  };

  # Generated with prefetch-npm-deps from a minimal package-lock.json with the required dependency
  npmDepsHash = "sha256-JlQ0eL+ivkSh1NsiMIogRP4wKW2WROwsSfTAeGmRbuo=";

  # Copy the package-lock.json file and modify package.json to remove devDependencies
  postPatch = ''
    cp ${./package-lock.json} package-lock.json

    # Remove devDependencies and scripts from package.json to avoid build issues
    ${nodejs}/bin/node -e "
      const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
      delete pkg.devDependencies;
      delete pkg.scripts;
      require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
  '';

  # The package is already built, so we don't need to run build scripts
  dontNpmBuild = true;

  # Skip install scripts to avoid running prepare script
  npmInstallFlags = [ "--ignore-scripts" ];

  # Skip tests as they are not included in the npm package
  doCheck = false;

  meta = with lib; {
    description = "MCP server for enabling memory for Claude through a knowledge graph";
    longDescription = ''
      mcp-server-memory is a Model Context Protocol server that provides memory
      capabilities for Claude through a knowledge graph. It allows Claude to store,
      retrieve, and reason about information across conversations.

      Features:
      - Knowledge graph-based memory storage
      - Persistent memory across conversations
      - Entity and relationship management
      - Search and retrieval capabilities
      - Model Context Protocol compatibility
      - Integration with Claude and other AI assistants
    '';
    homepage = "https://modelcontextprotocol.io";
    changelog = "https://github.com/modelcontextprotocol/servers/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "mcp-server-memory";
  };
}
