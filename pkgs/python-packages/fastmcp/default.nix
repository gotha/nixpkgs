{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "fastmcp";
  version = "2.3.4";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-8/4AS4c1s2WmXsJUfutH24NS1WE2lyVIVLx8nDw2Duo=";
  };

  build-system = with python3.pkgs; [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = with python3.pkgs; [
    mcp
    pydantic
    openapi-pydantic
    uvicorn
    starlette
    httpx
    click
    python-dotenv
    exceptiongroup
    rich
    typer
    websockets
  ];

  # Disable tests as they likely require additional test dependencies
  doCheck = false;

  pythonImportsCheck = [
    "fastmcp"
  ];

  meta = with lib; {
    description = "The fast, Pythonic way to build MCP servers and clients";
    longDescription = ''
      FastMCP is a Python library that provides a fast and easy way to build
      Model Context Protocol (MCP) servers and clients. It offers a simple
      API for creating MCP-compatible applications.
    '';
    homepage = "https://github.com/jlowin/fastmcp";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
