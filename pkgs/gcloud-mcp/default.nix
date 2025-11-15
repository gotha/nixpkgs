{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

buildNpmPackage rec {
  pname = "gcloud-mcp";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "gcloud-mcp";
    rev = "gcloud-mcp-v${version}";
    hash = "sha256-IlPcFIfTeQmHDtLInZtCLnw4nkLeyeeh/YoktVk5Bn8=";
  };

  # Generated with prefetch-npm-deps from the root package-lock.json
  npmDepsHash = "sha256-HvkmzSe3I+5v3kXly0VsPto0f2Mlj179HC8c+T7eN6E=";

  # For monorepo, we need to build from the root and specify the workspace
  npmWorkspace = "packages/gcloud-mcp";

  # Build the TypeScript source
  npmBuildScript = "build";

  # Skip tests as they likely require GCP credentials and network access
  doCheck = false;

  # Disable broken symlinks check for monorepo workspace packages
  dontFixup = false;
  preFixup = ''
    # Remove broken symlinks from other workspace packages
    find $out -type l ! -exec test -e {} \; -delete || true
  '';

  meta = with lib; {
    description = "Model Context Protocol (MCP) Server for interacting with GCP APIs";
    longDescription = ''
      gcloud-mcp is a Model Context Protocol server that provides tools for
      interacting with Google Cloud Platform (GCP) APIs through natural language.
      Instead of memorizing complex gcloud commands, you can describe the outcome
      you want and the server will execute the appropriate GCP operations.

      Features:
      - Natural language interface to GCP APIs
      - Integration with gcloud CLI
      - Support for various GCP services
      - Model Context Protocol compatibility for AI assistants
      - Secure authentication through gcloud credentials
    '';
    homepage = "https://github.com/googleapis/gcloud-mcp";
    changelog = "https://github.com/googleapis/gcloud-mcp/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "gcloud-mcp";
  };
}
