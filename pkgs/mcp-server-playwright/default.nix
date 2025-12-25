{ lib, buildNpmPackage, fetchurl, nodejs }:

buildNpmPackage rec {
  pname = "mcp-server-playwright";
  version = "0.0.53";

  src = fetchurl {
    url = "https://registry.npmjs.org/@playwright/mcp/-/mcp-${version}.tgz";
    hash = "sha256-WSrfOgYJdF0YJf/7s9Yn7oUA+jRKw9xumYwvDoD4v38=";
  };

  # Generated with prefetch-npm-deps from a minimal package-lock.json with the required dependencies
  npmDepsHash = "sha256-lIEUprWURswVM1ccAXiIIegHrfBdetwHHN3A5GmekcM=";

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
    description = "Playwright MCP server for browser automation via Model Context Protocol";
    longDescription = ''
      mcp-server-playwright is a Model Context Protocol server that provides
      browser automation capabilities through Playwright. It enables AI assistants
      to interact with web browsers, perform web scraping, testing, and automation
      tasks.

      Features:
      - Core browser automation (click, type, navigate, etc.)
      - Tab management
      - Screenshot and PDF generation
      - Coordinate-based interactions (vision capability)
      - Test assertions and locator generation
      - Network request monitoring
      - Console message capture
      - Trace recording
      - Support for Chromium, Firefox, and WebKit browsers
      - Headless and headed browser modes
      - Docker support for containerized execution
      - Model Context Protocol compatibility
      - Integration with Claude and other AI assistants
    '';
    homepage = "https://github.com/microsoft/playwright-mcp";
    changelog = "https://github.com/microsoft/playwright-mcp/releases";
    license = licenses.asl20;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "mcp-server-playwright";
  };
}

