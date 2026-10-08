{ lib, python3, fetchFromGitHub }:

python3.pkgs.buildPythonApplication rec {
  pname = "kubectl-mcp-server";
  version = "1.24.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rohitg00";
    repo = "kubectl-mcp-server";
    tag = "v${version}";
    hash = "sha256-i+nxgykqskZe5th4mgdHyqVfmM0OlHx1cAn8bSXOKRY=";
  };

  # The release has setup.py but no pyproject.toml.
  postPatch = ''
    cat > pyproject.toml <<'EOF'
    [build-system]
    requires = ["setuptools"]
    build-backend = "setuptools.build_meta"
    EOF

    # v1.24.0 passes a removed constructor argument from the kubectl-mcp entry point.
    substituteInPlace kubectl_mcp_tool/__main__.py \
      --replace-fail 'non_destructive=args.non_destructive' 'disable_destructive=args.non_destructive'
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    fastmcp
    mcp
    pydantic
    fastapi
    uvicorn
    starlette
    kubernetes
    pyyaml
    requests
    urllib3
    websocket-client
    jsonschema
    cryptography
    rich
    aiohttp
    aiohttp-sse
  ];

  # Tests require a Kubernetes cluster.
  doCheck = false;

  pythonImportsCheck = [ "kubectl_mcp_tool" ];

  # Keep the binary name used by the flake app.
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
    changelog = "https://github.com/rohitg00/kubectl-mcp-server/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "kubectl-mcp-server";
    platforms = platforms.unix;
  };
}
