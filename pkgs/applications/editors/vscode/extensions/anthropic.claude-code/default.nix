{
  lib,
  vscode-utils,
  claude-code,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "claude-code";
    publisher = "anthropic";
    version = "2.0.75";
    hash = "sha256-LXUIp+Rqh0prvFLgmbiSVJYHNY2ECVAfK8GLmDRMcxU=";
  };

  postInstall = ''
    rm -f "$out/$installPrefix/resources/native-binary/claude"
    ln -s "${claude-code}/bin/claude" "$out/$installPrefix/resources/native-binary/claude"
  '';

  meta = {
    description = "Harness the power of Claude Code without leaving your IDE";
    homepage = "https://docs.anthropic.com/s/claude-code";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
  };
}
