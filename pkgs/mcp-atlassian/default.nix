{ lib, python3, markdown-to-confluence, fastmcp }:

python3.pkgs.buildPythonApplication rec {
  pname = "mcp-atlassian";
  version = "0.11.9";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    pname = "mcp_atlassian";
    inherit version;
    hash = "sha256-G6ahcbUpnlVNTg7/mCeedM3E6xwSyOYr6SQQPZzTjl4=";
  };

  build-system = with python3.pkgs; [ hatchling uv-dynamic-versioning ];

  dependencies = with python3.pkgs; [
    # Core dependencies - all available in nixpkgs!
    atlassian-python-api
    requests
    beautifulsoup4
    httpx
    mcp
    python-dotenv

    markdownify
    markdown
    pydantic
    trio
    click
    uvicorn
    starlette
    thefuzz
    python-dateutil
    keyring
    cachetools

    fastmcp
    markdown-to-confluence

    # Only these are missing from nixpkgs:
    # - types-python-dateutil (type stubs, not runtime critical)
    # - types-cachetools (type stubs, not runtime critical)
  ];

  # Disable tests as they require network access and Atlassian credentials
  doCheck = false;

  # Disable runtime dependency checks due to version constraint issues
  dontCheckRuntimeDeps = true;

  meta = with lib; {
    description =
      "Model Context Protocol (MCP) server for Atlassian tools (Confluence, Jira)";
    longDescription = ''
      MCP Atlassian is a Model Context Protocol server that provides integration
      with Atlassian tools like Jira and Confluence. This package is built from
      the PyPI distribution and includes all major dependencies including
      custom-packaged fastmcp (v2.3.4), markdown-to-confluence (v0.3.5),
      and json-strong-typing (v0.4.1).
    '';
    homepage = "https://github.com/sooperset/mcp-atlassian";
    changelog =
      "https://github.com/sooperset/mcp-atlassian/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "mcp-atlassian";
  };
}
