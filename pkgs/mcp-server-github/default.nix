{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

buildNpmPackage rec {
  pname = "mcp-server-github";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "servers";
    rev = "typescript-servers-${version}";
    hash = "sha256-FKotJUzP29iZzfRqfWGhdZosWxGX7BBOExxznfLi7Us=";
  };

  # Generated with prefetch-npm-deps from the root package-lock.json
  npmDepsHash = "sha256-fuJQxbHrv/x49I3WDMQxXC/+kuv/JiTDdHiAEaN94Zw=";

  # For monorepo, we need to build from the root and specify the workspace
  npmWorkspace = "src/github";

  # Build the TypeScript source
  npmBuildScript = "build";

  # Skip tests as they likely require GitHub credentials and network access
  doCheck = false;

  # Skip Puppeteer browser download during build
  env = {
    PUPPETEER_SKIP_DOWNLOAD = "true";
  };

  # Disable broken symlinks check for monorepo workspace packages
  dontFixup = false;
  preFixup = ''
    # Remove broken symlinks from other workspace packages
    find $out -type l ! -exec test -e {} \; -delete || true
  '';

  meta = with lib; {
    description = "MCP server for using the GitHub API";
    longDescription = ''
      mcp-server-github is a Model Context Protocol server that provides tools for
      interacting with the GitHub API. It enables file operations, repository management,
      search functionality, and more through natural language commands.

      Note: This package is based on the deprecated @modelcontextprotocol/server-github
      npm package. While still functional, users may want to consider alternative
      GitHub MCP servers from the community.

      Features:
      - GitHub API integration
      - File operations (read, write, create, delete)
      - Repository management
      - Search functionality
      - Issue and pull request management
      - Model Context Protocol compatibility
    '';
    homepage = "https://github.com/modelcontextprotocol/servers";
    changelog = "https://github.com/modelcontextprotocol/servers/releases/tag/typescript-servers-${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "mcp-server-github";
  };
}
