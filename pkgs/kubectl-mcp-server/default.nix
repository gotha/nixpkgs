{ lib, python3, fetchFromGitHub, makeWrapper }:

python3.pkgs.buildPythonApplication rec {
  pname = "kubectl-mcp-server";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rohitg00";
    repo = "kubectl-mcp-server";
    rev = "f0986f3f3817283cf945b00ffb1329a3beef5f0e";
    hash = "sha256-FOL6IDVp3hirwkv6KX0kH7ih3OckZ8a8jQq5oBowJ4g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  build-system = with python3.pkgs; [
    setuptools
    wheel
    build
  ];

  dependencies = with python3.pkgs; [
    # MCP framework
    mcp
    
    # Core web framework dependencies
    pydantic
    fastapi
    uvicorn
    
    # Kubernetes dependencies
    kubernetes
    pyyaml
    requests
    urllib3
    websocket-client
    jsonschema
    cryptography
    
    # Additional dependencies
    rich
    aiohttp
    aiohttp-sse
  ];

  # Skip tests during build (they require a Kubernetes cluster)
  doCheck = false;

  # Rename the binary from kubectl-mcp to kubectl-mcp-server
  postInstall = ''
    mv $out/bin/kubectl-mcp $out/bin/kubectl-mcp-server
  '';


  meta = with lib; {
    description = "Model Context Protocol (MCP) server for Kubernetes";
    longDescription = ''
      kubectl-mcp-server is a Model Context Protocol (MCP) server that provides
      AI assistants with the ability to interact with Kubernetes clusters through
      kubectl commands. It supports both stdio and SSE transports and includes
      features for resource management, monitoring, and natural language processing
      of Kubernetes operations.

      Key features:
      - Full kubectl command execution through MCP
      - Support for both stdio and SSE transports
      - Kubernetes resource management and monitoring
      - Natural language processing for Kubernetes operations
      - Security features and diagnostics
      - Compatible with AI assistants like Claude, ChatGPT, and others
    '';
    homepage = "https://github.com/rohitg00/kubectl-mcp-server";
    changelog = "https://github.com/rohitg00/kubectl-mcp-server/blob/v${version}/CHANGES.md";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "kubectl-mcp-server";
    platforms = platforms.unix;
  };
}
