{ lib, stdenvNoCC, nodejs, makeWrapper }:

stdenvNoCC.mkDerivation rec {
  pname = "gcloud-mcp";
  version = "0.4.0";

  # Fetch the pre-built package from npm registry using builtins.fetchTarball
  src = builtins.fetchTarball {
    url = "https://registry.npmjs.org/@google-cloud/gcloud-mcp/-/gcloud-mcp-${version}.tgz";
    sha256 = "1qpsqxyrv2jw5yiskkw9c6lkr6zzhvk5f8zagh4v1w9gck6hczaa";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/lib/node_modules/@google-cloud/gcloud-mcp
    mkdir -p $out/bin

    # Copy the package contents
    cp -r . $out/lib/node_modules/@google-cloud/gcloud-mcp/

    # Create wrapper script for the binary
    makeWrapper ${nodejs}/bin/node $out/bin/gcloud-mcp \
      --add-flags "$out/lib/node_modules/@google-cloud/gcloud-mcp/dist/bundle.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Model Context Protocol (MCP) Server for interacting with GCP APIs";
    homepage = "https://github.com/googleapis/gcloud-mcp";
    license = licenses.asl20;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "gcloud-mcp";
  };
}
