{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mcp-server-github";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "github";
    repo = "github-mcp-server";
    rev = "v${version}";
    hash = "sha256-diL1aIVxsR1Bl+HeWuZiFe3s9Xt4B6jYW8PBkBZu+Kk=";
  };

  vendorHash = "sha256-q4Fy/dfnzLuMuZ27KO3MogGP/XdJbmOUISBkoTNPUUk=";

  # Skip tests as they require GitHub credentials and network access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Official GitHub MCP server - connects AI tools to GitHub";
    longDescription = ''
      The GitHub MCP Server connects AI tools directly to GitHub's platform. This gives
      AI agents, assistants, and chatbots the ability to read repositories and code files,
      manage issues and PRs, analyze code, and automate workflows through natural language.

      This is the official GitHub MCP server, now maintained by GitHub (previously by
      the Model Context Protocol team). It has been completely rewritten in Go for
      better performance and reliability.

      Key Features:
      - Repository Management: Browse code, search files, analyze commits, understand project structure
      - Issue & PR Automation: Create, update, and manage issues and pull requests
      - CI/CD & Workflow Intelligence: Monitor GitHub Actions, analyze build failures, manage releases
      - Code Analysis: Examine security findings, review Dependabot alerts, understand code patterns
      - Team Collaboration: Access discussions, manage notifications, analyze team activity

      Use Cases:
      - Natural language queries about your codebase
      - Automated issue triage and PR reviews
      - CI/CD pipeline monitoring and analysis
      - Security and dependency management
      - Team collaboration and workflow automation
    '';
    homepage = "https://github.com/github/github-mcp-server";
    changelog = "https://github.com/github/github-mcp-server/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "github-mcp-server";
  };
}
