{
  lib,
  vscode-utils,
  autoPatchelfHook,
  patchelf,
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

  base =
    supported.${system}
      or (throw "Unsupported system: ${system}");

  # First stage: build with autoPatchelfHook
  unpacked = vscode-utils.buildVscodeMarketplaceExtension {
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
  };

  # Second stage: fix dlopen RPATH for audio.sys.so
  # The core.so library uses dlopen to load audio.sys.so at runtime.
  # autoPatchelfHook patches the direct dependencies but can't detect dlopen calls.
  # We copy the extension and re-patch ALL native libraries to:
  # 1. Update RPATHs from the unpacked store path to our new $out path
  # 2. Add the Release directory to core.so's RPATH for dlopen
in
stdenv.mkDerivation {
  pname = "vscode-extension-ms-vscode-vscode-speech";
  version = "0.16.0";

  dontUnpack = true;

  nativeBuildInputs = [ patchelf ];

  # Pass through attributes that home-manager/vscode-utils expects
  inherit (unpacked) vscodeExtUniqueId vscodeExtPublisher vscodeExtName;

  installPhase = ''
    runHook preInstall

    cp -r ${unpacked} $out
    chmod -R u+w $out

    releaseDir="$out/share/vscode/extensions/ms-vscode.vscode-speech/node_modules/@vscode/node-speech/build/Release"

    # Update all native libraries to use the new store path instead of the old one
    for lib in "$releaseDir"/*.so "$releaseDir"/*.node; do
      if [ -f "$lib" ]; then
        oldRpath=$(patchelf --print-rpath "$lib" 2>/dev/null || true)
        if [ -n "$oldRpath" ]; then
          # Replace old store path with new one in RPATH
          newRpath=$(echo "$oldRpath" | sed "s|${unpacked}|$out|g")
          patchelf --set-rpath "$newRpath" "$lib"
        fi
      fi
    done

    # Also add the Release directory to core.so's RPATH for dlopen of audio.sys.so
    patchelf --add-rpath "$releaseDir" "$releaseDir/libMicrosoft.CognitiveServices.Speech.core.so"

    runHook postInstall
  '';

  inherit (unpacked) meta;
}
