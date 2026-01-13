{
  lib,
  vscode-utils,
  autoPatchelfHook,
  stdenv,
  alsa-lib,
  libuuid,
}:

let
  inherit (stdenv.hostPlatform) system;

  supported = {
    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-dZwOBehoYEqaYskvcPB55IKnG1CMToioyUJXlndqorA=";
    };
    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-Dj+E1hPLaO2SCBvYqn3zfyJnNz30/V0xR2T8q8VNkXE=";
    };
  };

  base = supported.${system} or (throw "Unsupported system: ${system}");

  releaseDir = "share/vscode/extensions/ms-vscode.vscode-speech/node_modules/@vscode/node-speech/build/Release";
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = base // {
    name = "vscode-speech";
    publisher = "ms-vscode";
    version = "0.16.0";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    libuuid
  ];

  # Prevent fixup phase from shrinking RPATHs - we need the Release directory
  # in the RPATH for dlopen to find audio.sys.so at runtime
  dontPatchELF = true;

  # The core.so library uses dlopen to load audio.sys.so at runtime.
  # autoPatchelfHook patches direct dependencies but can't detect dlopen calls,
  # so we add the Release directory to RPATH.
  appendRunpaths = [
    "${placeholder "out"}/${releaseDir}"
  ];

  meta = {
    description = "Enables speech-to-text and text-to-speech capabilities in VS Code";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-speech";
    homepage = "https://github.com/microsoft/vscode-speech";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
