{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "chump";
  version = "1.6.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f4659f39849c69e32e939b97bec53550f1e30055fdbd81d52b6564d1153255ee";
  };

  doCheck = false;

  meta = with lib; {
    description = "A fully featured API wrapper for Pushover.";
    homepage = "https://github.com/karanlyons/chump";
    license = licenses.asl20;
  };
}
