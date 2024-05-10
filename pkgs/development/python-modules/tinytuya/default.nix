{ lib
, buildPythonPackage
, fetchFromGitHub

  # build-system
, setuptools-scm

# dependencies
, cryptography
, requests
, colorama
}:

buildPythonPackage rec {
  pname = "tinytuya";
  version = "1.13.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jasonacox";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-44x5P+Ej/d6B5n53iDuLDBzkeZZvArpcgzXLJBcIJe0=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    cryptography
    requests
    colorama
  ];

  # Tests require real network resources
  doCheck = false;

  meta = with lib; {
    description = "Python API for Tuya WiFi smart devices using a direct local area network (LAN) connection or the cloud (TuyaCloud API).";
    homepage = "https://github.com/jasonacox/tinytuya";
    changelog = "https://github.com/jasonacox/tinytuya/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
  };
}
