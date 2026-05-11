{
  description = "IA Client UI Module";

  inputs = {
    logos-module-builder.url = "/home/vpavlin/devel/logos-module-builder-patched";
    logos-ia.url = "/home/vpavlin/devel/logos-ia";
  };

  outputs = inputs@{ logos-module-builder, logos-ia, ... }:
    let
      # Get the include directory from logos-ia's output
      logosIaIncludeDir = "${logos-ia.defaultPackage}/include";
      
      # Build as QML module (no C++ compilation)
      iaUiModule = (builtins.getAttr "mkLogosQmlModule" inputs.logos-module-builder.lib) {
        src = ./.;
        configFile = ./metadata.json;
        flakeInputs = inputs;
      };
    in
    iaUiModule;
}
