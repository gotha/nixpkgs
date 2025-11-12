{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "json-strong-typing";
  version = "0.4.1";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    pname = "json_strong_typing";
    inherit version;
    hash = "sha256-dlJudncgIr727yLLeyG1TQX2+di1IfQUYPJ92n0YfqU=";
  };

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  dependencies = with python3.pkgs; [
    jsonschema
  ];

  # Disable tests as they likely require additional test dependencies
  doCheck = false;

  pythonImportsCheck = [
    "strong_typing"
    "strong_typing.core"
  ];

  meta = with lib; {
    description = "Type-safe data interchange for Python data classes";
    longDescription = ''
      JSON is a popular message interchange format employed in API design for its 
      simplicity, readability, flexibility and wide support. This package offers 
      services for working with strongly-typed Python classes: serializing objects 
      to JSON, deserializing JSON to objects, and producing a JSON schema that 
      matches the data class.
    '';
    homepage = "https://pypi.org/project/json-strong-typing/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
