{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, xorg
, dbus
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "goose";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "block";
    repo = "goose";
    rev = "v${version}";
    hash = "sha256-MEFHVuTejAn1vwTwaxM7XEBSCuFAwLwjptIhKHR6cMM=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      # Patch required for Windows cross-compilation
      # See: https://github.com/nmathewson/crunchy/tree/cross-compilation-fix
      "crunchy-0.2.3" = "sha256-CBW3/JuMoNa6MWia6BQo07LQrH5JQbb20vuCqhyFL0Y=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    xorg.libxcb  # Required for xcap screenshot functionality
    dbus         # Required for system integration features
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    Security
    SystemConfiguration
    CoreServices
  ]);

  # Build only the CLI package
  cargoBuildFlags = [ "--package" "goose-cli" ];

  # Enable tests with proper environment
  doCheck = true;
  checkPhase = ''
    export HOME=$(mktemp -d)
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_STATE_HOME=$HOME/.local/state
    export XDG_CACHE_HOME=$HOME/.cache
    mkdir -p $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME
    
    # Run tests for goose-cli package only
    cargo test --package goose-cli --release
  '';

  meta = with lib; {
    description = "An open source, extensible AI agent that goes beyond code suggestions";
    longDescription = ''
      goose is your on-machine AI agent, capable of automating complex development 
      tasks from start to finish. More than just code suggestions, goose can build 
      entire projects from scratch, write and execute code, debug failures, 
      orchestrate workflows, and interact with external APIs - autonomously.

      Whether you're prototyping an idea, refining existing code, or managing 
      intricate engineering pipelines, goose adapts to your workflow and executes 
      tasks with precision.

      Designed for maximum flexibility, goose works with any LLM and supports 
      multi-model configuration to optimize performance and cost, seamlessly 
      integrates with MCP servers, and is available as both a desktop app as well 
      as CLI - making it the ultimate AI assistant for developers who want to move 
      faster and focus on innovation.
    '';
    homepage = "https://github.com/block/goose";
    changelog = "https://github.com/block/goose/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "goose";
    platforms = platforms.unix;
  };
}
