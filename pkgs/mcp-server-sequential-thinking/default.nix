{ lib, buildNpmPackage, fetchurl, nodejs }:

buildNpmPackage rec {
  pname = "mcp-server-sequential-thinking";
  version = "2025.12.18";

  src = fetchurl {
    url = "https://registry.npmjs.org/@modelcontextprotocol/server-sequential-thinking/-/server-sequential-thinking-${version}.tgz";
    hash = "sha256-WiHm+kc3IrjmIqm7vdcrxtvN30MPJqtZic0z3+XcdwM=";
  };

  # Generated with prefetch-npm-deps from a minimal package-lock.json with the required dependencies
  npmDepsHash = "sha256-Td3vl9OMNg0mUMCuSunhVnq1+Jlo0PrqwnAepr9dmgs=";

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
    description = "MCP server for sequential thinking and problem solving";
    longDescription = ''
      mcp-server-sequential-thinking is a Model Context Protocol server that provides
      dynamic and reflective problem-solving through sequential thought processes.
      It enables AI assistants to break down complex problems into manageable steps
      and think through solutions systematically.

      Features:
      - Sequential thought processing
      - Dynamic problem-solving approach
      - Reflective thinking capabilities
      - Step-by-step analysis
      - Complex problem breakdown
      - Model Context Protocol compatibility
      - Integration with Claude and other AI assistants
    '';
    homepage = "https://modelcontextprotocol.io";
    changelog = "https://github.com/modelcontextprotocol/servers/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "mcp-server-sequential-thinking";
  };
}
