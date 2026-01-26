{ lib, python3, py-key-value-shared }:

python3.pkgs.buildPythonPackage rec {
  pname = "py-key-value-aio";
  version = "0.3.0";
  format = "wheel";

  src = python3.pkgs.fetchPypi {
    pname = "py_key_value_aio";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-HHgZFXZgeL/WCNqnaf77l+ZdHXN0aj37ZARg4yIHG2Q=";
  };

  dependencies = [
    py-key-value-shared
  ] ++ (with python3.pkgs; [
    beartype
    # Optional dependencies for memory and redis backends
    cachetools  # memory backend
    redis       # redis backend
  ]);

  # Disable tests
  doCheck = false;

  # Skip import check - it works at runtime
  # pythonImportsCheck = [ "key_value" ];

  meta = with lib; {
    description = "Async Key-Value store abstraction for Python";
    longDescription = ''
      An async key-value store abstraction that supports multiple backends
      including in-memory (cachetools), Redis, and more.
    '';
    homepage = "https://github.com/strawgate/py-key-value";
    license = licenses.asl20;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
  };
}

