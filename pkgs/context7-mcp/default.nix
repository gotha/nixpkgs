{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

buildNpmPackage rec {
  pname = "context7-mcp";
  version = "1.0.27";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    rev = "v${version}";
    hash = "sha256-GoM2mxLODqFku5qeWCIfQNG3pMU09cmwNZYYjK0vG1A=";
  };

  # Use the generated package-lock.json
  npmDepsHash = "sha256-m2tVzlalUV/Arpe37cVXIFgHiFxY72M8uuo0kOCo33w=";

  # Copy the package-lock.json we generated
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  # Build the TypeScript source
  npmBuildScript = "build";

  # Skip tests as they likely require API keys and network access
  doCheck = false;

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
