{ lib, python3, py-key-value-aio }:

python3.pkgs.buildPythonPackage rec {
  pname = "pydocket";
  version = "0.17.1";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-3ls5JB9yjCwKu8tBmwzTpeqz7UjiKMTHrdFbAuI0pow=";
  };

  build-system = with python3.pkgs; [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    py-key-value-aio
  ] ++ (with python3.pkgs; [
    cloudpickle
    fakeredis
    lupa  # Required by fakeredis for Lua scripting
    opentelemetry-api
    prometheus-client
    python-json-logger
    redis
    rich
    typer
    typing-extensions
    cachetools
  ]);

  # Disable tests as they require Redis server
  doCheck = false;

  # Disable runtime dependency checks
  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [
    "docket"
  ];

  meta = with lib; {
    description = "A distributed background task system for Python functions";
    longDescription = ''
      Docket is a distributed background task system for Python functions with
      a focus on the scheduling of future work as seamlessly and efficiently as
      immediate work. It is purpose-built for Redis streams and provides
      dependency injection like FastAPI, Typer, and FastMCP for reusable resources.
    '';
    homepage = "https://github.com/chrisguidry/docket";
    changelog = "https://github.com/chrisguidry/docket/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
  };
}

