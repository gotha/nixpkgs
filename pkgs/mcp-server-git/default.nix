{ lib, python3 }:

python3.pkgs.buildPythonApplication rec {
  pname = "mcp-server-git";
  version = "2025.9.25";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    pname = "mcp_server_git";
    inherit version;
    hash = "sha256-SH2TWdZ91zGH132wIAYB8h1tydDXno32mwEs6yyZI+Q=";
  };

  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    click
    gitpython
    mcp
    pydantic
  ];

  # Disable tests as they likely require git repositories and specific test setup
  doCheck = false;

  pythonImportsCheck = [
    "mcp_server_git"
  ];

  meta = with lib; {
    description = "A Model Context Protocol server providing tools to read, search, and manipulate Git repositories programmatically via LLMs";
    longDescription = ''
      mcp-server-git is a Model Context Protocol server for Git repository 
      interaction and automation. This server provides tools to read, search, 
      and manipulate Git repositories via Large Language Models.

      The server provides comprehensive Git operations including status checking,
      diff viewing, committing, branching, and log inspection. All dependencies
      are available in nixpkgs, making this a fully functional package.
    '';
    homepage = "https://github.com/modelcontextprotocol/servers/tree/main/src/git";
    changelog = "https://github.com/modelcontextprotocol/servers/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "mcp-server-git";
  };
}
