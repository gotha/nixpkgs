{ lib
, python3
, json-strong-typing
}:

python3.pkgs.buildPythonPackage rec {
  pname = "markdown-to-confluence";
  version = "0.3.5";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    pname = "markdown_to_confluence";
    inherit version;
    hash = "sha256-QwmvYlaC9tMA4ReZK4fmRZqK5rZT3uL5Empnis8Hbws=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    requests
    markdown
    pydantic
    python-dateutil
    lxml
    pyyaml
    pymdown-extensions
    truststore

    # Custom packages
    json-strong-typing

    # Note: Some optional dependencies might be missing:
    # - matplotlib (for LaTeX formula rendering)
    # - Additional dependencies for specific features
  ];

  # Disable tests as they likely require network access and Confluence credentials
  doCheck = false;

  # Disable runtime dependency checks due to missing type stubs
  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [
    "md2conf"
  ];

  meta = with lib; {
    description = "Publish Markdown files to Confluence wiki";
    longDescription = ''
      md2conf parses Markdown files, converts Markdown content into the 
      Confluence Storage Format (XHTML), and invokes Confluence API endpoints 
      to upload images and content.
    '';
    homepage = "https://github.com/hunyadi/md2conf";
    changelog = "https://github.com/hunyadi/md2conf/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "md2conf";
  };
}
