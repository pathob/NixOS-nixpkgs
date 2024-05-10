{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, pycountry
, tuya-iot-py-sdk
}:

buildHomeAssistantComponent rec {
  owner = "pathob";
  domain = "tuya_ble";
  version = "0.1.8";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha_tuya_ble";
    # rev = "refs/tags/${version}";
    rev = "support-ms-1nmdfdzp-smart-lock-cylinder";
    hash = "sha256-U4yWasgjH5VobYHSJfoPNcUCPCD9IbXCVnwYYvq82Tw=";
  };

  propagatedBuildInputs = [
    pycountry
    tuya-iot-py-sdk
  ];

  meta = with lib; {
    description = "";
    homepage = "";
    changelog = "";
    license = licenses.mit;
    maintainers = [ ];
  };
}
