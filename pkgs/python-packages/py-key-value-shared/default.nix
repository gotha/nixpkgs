{ lib, python3 }:

python3.pkgs.buildPythonPackage rec {
  pname = "py-key-value-shared";
  version = "0.3.0";
  format = "wheel";

  src = python3.pkgs.fetchPypi {
    pname = "py_key_value_shared";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-Ww77p+vKCLsVix6Tr8LwfTC49AwvwSziSkwNhPQvkpg=";
  };

  dependencies = with python3.pkgs; [
    typing-extensions
    beartype
  ];

  # Disable tests
  doCheck = false;

  pythonImportsCheck = [
    "key_value"
  ];

  meta = with lib; {
    description = "Shared code between key-value-aio and key-value-sync";
    homepage = "https://github.com/strawgate/py-key-value";
    license = licenses.asl20;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
  };
}

